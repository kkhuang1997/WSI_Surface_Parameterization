import warnings
warnings.filterwarnings('ignore')
import torch
import torch.nn as nn
import torchvision.transforms as transforms
from torch.utils.data import Dataset
from torch.utils.data import DataLoader
from ctran import ctranspath

from PIL import Image
import numpy as np
import os

# cuda settings
os.environ['CUDA_VISIBLE_DEVICES'] = '0,1,2,3' 
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

## get patch subfolders
def get_subfolders(folder_path):
    subfolders = []
    for item in os.listdir(folder_path):
        item_path = os.path.join(folder_path, item)
        if os.path.isdir(item_path):
            subfolders.append(item_path)
    return subfolders

# hyper parameter
batch_size = 1024
output_folder = '/SEM/feat'
folder_paths = get_subfolders('/SEM/patches')

# load ctranspath backbone
model = ctranspath()
model.head = nn.Identity()
td = torch.load(r'/ctranspath.pth')
model.load_state_dict(td['model'], strict=True)

model = nn.DataParallel(model, device_ids=[0,1,2,3])  
model.to(device)
model.eval()

#### CRC WSI feat extraction ####
mean = (0.485, 0.456, 0.406)
std = (0.229, 0.224, 0.225)
transform = transforms.Compose([
    transforms.Resize(224),
    transforms.ToTensor(),
    transforms.Normalize(mean = mean, std = std)
])

class ImageDataset(Dataset):
    def __init__(self, data_dir, transform=None):
        self.data_dir = data_dir
        self.image_list = os.listdir(data_dir)
        self.transform = transform

    def __len__(self):
        return len(self.image_list)

    def __getitem__(self, index):
        image_name = self.image_list[index]
        image_path = os.path.join(self.data_dir, image_name)

        image = Image.open(image_path).convert('RGB')

        if self.transform is not None:
            image = self.transform(image)

        return image

for folder_path in folder_paths:
    dataset = ImageDataset(folder_path, transform=transform)
    dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=False)

    embeddings = []
    with torch.no_grad():
        for images in dataloader:
            images = images.to(device)
            features = model(images)
            embeddings.append(features)

    embeddings = torch.cat(embeddings, dim=0)
    embeddings = embeddings.cpu().numpy()

    folder_name = os.path.basename(folder_path)
    os.makedirs(output_folder, exist_ok=True)
    output_file = os.path.join(output_folder, f'{folder_name}.npy')

    np.save(output_file, embeddings)
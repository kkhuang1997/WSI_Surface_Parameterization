import warnings
warnings.filterwarnings('ignore')

import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.optim.lr_scheduler import OneCycleLR
import torchvision.transforms as transforms
from torchvision.datasets import ImageFolder
from torch.utils.data import DataLoader
from torchvision import models
import numpy as np
from tqdm import tqdm

# cuda settings 
os.environ['CUDA_VISIBLE_DEVICES'] = '0,1,2,3' 
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# hyperparameters 
train_dataset_path = '/NCT-CRC-HE-100K'
val_dataset_path = '/CRC-VAL-HE-7K'
NUM_CLASS = 9
mean = [0.485, 0.456, 0.406]
std = [0.229, 0.224, 0.225]

train_transform = transforms.Compose([
    transforms.RandomResizedCrop(224),
    transforms.RandomHorizontalFlip(),
    transforms.RandomVerticalFlip(),
    transforms.ToTensor(),
    transforms.Normalize(mean=mean, std=std)
])

val_transform = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=mean, std=std)
])

train_dataset = ImageFolder(root=train_dataset_path, transform=train_transform)
val_dataset = ImageFolder(root=val_dataset_path, transform=val_transform)
train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True, num_workers=4)
val_loader = DataLoader(val_dataset, batch_size=64, shuffle=False, num_workers=4)

# Load pre-trained ResNet34 model
model = models.resnet34(pretrained=True)
for param in model.parameters():
    param.requires_grad = False

num_ftrs = model.fc.in_features
model.fc = nn.Sequential(
    nn.Linear(num_ftrs, 256),
    nn.ReLU(),
    nn.Dropout(p=0.25),
    nn.Linear(256, NUM_CLASS),  
)

criterion = nn.CrossEntropyLoss() 
optimizer = optim.Adam(model.parameters(), lr=0.01)
scheduler = OneCycleLR(optimizer, max_lr=0.01, epochs=10,
                       steps_per_epoch=len(train_loader), div_factor=10, final_div_factor=1)

def calculate_accuracy(outputs, labels):
    _, preds = torch.max(outputs, 1) 
    correct = (preds == labels).sum().item()
    return correct / labels.size(0)

# training
model = nn.DataParallel(model, device_ids=[0,1,2,3]) 
model = model.to(device)
best_val_accuracy = 0.0  
for epoch in tqdm(range(10)): 
    model.train()
    epoch_loss = 0.0
    epoch_accuracy = 0.0
    
    for inputs, labels in train_loader:
        inputs, labels = inputs.to(device), labels.long().to(device)
        
        optimizer.zero_grad()
        outputs = model(inputs).squeeze()  
        loss = criterion(outputs, labels)  
        loss.backward() 
        optimizer.step() 
        
        epoch_loss += loss.item() * inputs.size(0)
        epoch_accuracy += calculate_accuracy(outputs, labels) * inputs.size(0)
    
    epoch_loss /= len(train_loader.dataset)
    epoch_accuracy /= len(train_loader.dataset)
    
    print(f'Epoch {epoch+1}/{10}, '
          f'Train Loss: {epoch_loss:.4f}, '
          f'Train Accuracy: {epoch_accuracy:.4f}')
    
    # Valid
    model.eval()
    val_loss = 0.0
    val_accuracy = 0.0
    
    with torch.no_grad():
        for inputs, labels in val_loader:
            inputs, labels = inputs.to(device), labels.long().to(device)
            outputs = model(inputs).squeeze()
            loss = criterion(outputs, labels)
            
            val_loss += loss.item() * inputs.size(0)
            val_accuracy += calculate_accuracy(outputs, labels) * inputs.size(0)
    
    val_loss /= len(val_loader.dataset)
    val_accuracy /= len(val_loader.dataset)
    
    print(f'Validation Loss: {val_loss:.4f}, '
          f'Validation Accuracy: {val_accuracy:.4f}')
    
    
    if val_accuracy > best_val_accuracy:
        best_val_accuracy = val_accuracy
        torch.save(model, '/best_model.pth')
        print('Saved new best model')

    scheduler.step()

print('Training finished.')

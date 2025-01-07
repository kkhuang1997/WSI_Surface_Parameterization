import warnings
warnings.filterwarnings('ignore')
import os
import numpy as np
import pandas as pd
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, random_split
from torch.utils.data import Dataset
from tqdm import tqdm
from sklearn.metrics import roc_auc_score, accuracy_score
from models.aggregators.transformer import Transformer

# cuda settings
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
torch.cuda.set_device(1)

# hyper parameter
npy_data_dir = '/SEM/feat'
label_file = '/merged_clinical_molecular_public_tcga_survival.csv'
label_column = 'cms_label' 
batch_size = 1 
num_epochs = 10
learning_rate = 0.001

class Net(nn.Module):
    def __init__(self):	
        super(Net, self).__init__()
        self.aggregator_layer = Transformer(num_classes=5, input_dim=768)
        # self.aggregator_layer = AttentionMIL(input_dim=768, num_classes=2, num_features=1024)
        
    def forward(self, x):
        x = self.aggregator_layer(x)
        return x

#### CRC classification task ####
class CustomDataset(Dataset):
    def __init__(self, data_dir, label_file, label_column):
        self.data_dir = data_dir
        self.label_file = label_file
        self.label_column = label_column

        self.data_files = sorted([f for f in os.listdir(data_dir) if f.endswith('.npy')])
        self.label_dict = self._load_labels()

    def __len__(self):
        return len(self.data_files)

    def __getitem__(self, index):
        data_file = self.data_files[index]
        data_path = os.path.join(self.data_dir, data_file)
        data = np.load(data_path)

        tcga_sample = self._extract_substring(data_file)
        label = self.label_dict[tcga_sample]

        if label == -1:  ## label is nan
            return self.__getitem__((index + 1) % len(self))
        
        return data, label

    def _load_labels(self):
        label_df = pd.read_csv(self.label_file)
        label_df['Category'] = pd.Categorical(label_df[self.label_column])
        label_df['Category_Code'] = label_df['Category'].cat.codes
        label_dict = dict(zip(label_df["sample"], label_df['Category_Code']))
        return label_dict

    ## extract "TCGA-A6-2671"-like patterns
    def _extract_substring(self, string):
        parts = string.split("-")
        substring = "-".join(parts[:3])
        return substring

dataset = CustomDataset(data_dir=npy_data_dir, label_file=label_file, label_column=label_column)
train_size = 1900
valid_size = len(dataset) - train_size
train_dataset, valid_dataset = random_split(dataset, [train_size, valid_size])

train_loader = DataLoader(dataset=train_dataset, batch_size=batch_size, shuffle=True)
val_loader = DataLoader(dataset=valid_dataset, batch_size=batch_size, shuffle=False)

model = Net()
model = model.to(device)
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

# training
total_step = len(train_loader)
for epoch in tqdm(range(num_epochs)):
    model.train()
    for i, (npys, labels) in enumerate(train_loader):
        npys = npys.to(device)
        labels = labels.long()
        labels = labels.to(device)

        outputs = model(npys)
        loss = criterion(outputs, labels)
        
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        
        if (i+1) % 100 == 0:
            print(f'Epoch [{epoch+1}/{num_epochs}], Step [{i+1}/{total_step}], Loss: {loss.item():.4f}')

    # valid
    model.eval()
    with torch.no_grad():
        correct = 0
        total = 0
        preds = torch.Tensor()
        trues = torch.Tensor()
        for npys, labels in val_loader:
            npys = npys.to(device)
            labels = labels.to(device)

            outputs = model(npys)
            pred = torch.nn.functional.softmax(outputs)
            preds = torch.cat((preds, pred.cpu()), 0)
            trues = torch.cat((trues, labels.cpu()), 0)

        acc = accuracy_score(trues, np.argmax(preds, axis=1))
        ## for multiclass classification using one-vs-rest 
        auc = roc_auc_score(trues, preds, multi_class='ovr')
        ## for binary classification
        # auc = roc_auc_score(trues, preds[:,1])
        print(f'Accuracy on the validation set: {acc:.2f}%. AUC on the validation set: {auc:.2f}.')

        np.save(f'/preds_SEM5000_epoch{epoch}.npy', preds)
        np.save(f'/trues_SEM5000_epoch{epoch}.npy', trues)
        
# save model
torch.save(model.state_dict(), '/SEM5000.pth')
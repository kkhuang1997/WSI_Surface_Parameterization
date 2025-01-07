## plotting of
## receiver-operator-curves (ROC)
## precision-recall-curves (PRC)

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.pylab as pl
import pandas as pd
from tqdm import tqdm
from sklearn.metrics import roc_curve, roc_auc_score, auc, precision_recall_curve, average_precision_score
import torch

# load predictions for valid npys using the 10th epoch 
y_preds = []
y_trues = []
for i in range(5):
    y_preds.append(np.load(f'/fold{i+1}/preds_SEM5000_epoch9.npy'))
    y_trues.append(np.load(f'/fold{i+1}/trues_SEM5000_epoch9.npy'))

## Plot ROC curves
tprs = []
aucs = []
mean_fpr = np.linspace(0, 1, 100)
fig, ax = plt.subplots(figsize=(6, 5))

for i in range(len(y_trues)):
    fpr, tpr, _ = roc_curve(y_trues[i], y_preds[i][:, 1])
    roc_auc = roc_auc_score(y_trues[i], y_preds[i][:, 1])

    plt.plot(fpr, tpr, lw=1, label=f'Fold {i+1} (AUC = {roc_auc:.2f})', color=pl.cm.viridis(i*(1/len(y_trues))))

    interp_tpr = np.interp(mean_fpr, fpr, tpr)
    interp_tpr[0] = 0.0
    tprs.append(interp_tpr)
    aucs.append(roc_auc)

# print(aucs)
ax.plot([0, 1], [0, 1], linestyle="--", lw=1, color="gray", label="Chance", alpha=0.8)

mean_tpr = np.mean(tprs, axis=0)
mean_tpr[-1] = 1.0
mean_auc = auc(mean_fpr, mean_tpr)
std_auc = np.std(aucs)

# plot mean curve
ax.plot(
    mean_fpr,
    mean_tpr,
    color="black",
    label=r"Mean ROC (AUC = %0.2f $\pm$ %0.3f)" % (np.round(mean_auc, 2), np.round(std_auc, 3)),
    lw=2,
    alpha=0.8,
)

std_tpr = np.std(tprs, axis=0)
tprs_upper = np.minimum(mean_tpr + std_tpr, 1)
tprs_lower = np.maximum(mean_tpr - std_tpr, 0)
ax.fill_between(
    mean_fpr,
    tprs_lower,
    tprs_upper,
    color="grey",
    alpha=0.5,
    label=r"$\pm$ 1 std. dev.",
)

ax.set(
    xlim=[-0.05, 1.05],
    ylim=[-0.05, 1.05],
    # title=f"ROC for {test_cohorts} (target: {cfg.target})",
)

ax.set_xlabel('1 - Specificity')
ax.set_ylabel('Sensitivity')

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

ax.legend(loc="lower right")
fig.savefig('/roc_SEM5000.pdf', bbox_inches = 'tight', pad_inches = 1)

## Plot PR curve
plt.clf()
precs = []
aucs = []
mean_recall = np.linspace(0, 1, 100)

fig, ax = plt.subplots(figsize=(6, 5))
for i in range(len(y_trues)):
    prec, rec, _ = precision_recall_curve(y_trues[i], y_preds[i][:, 1])
    prec, rec = prec[::-1], rec[::-1]  
    pr_auc = average_precision_score(y_trues[i], y_preds[i][:, 1])
    
    ax.plot(rec, prec, label=f'Fold {i+1} (AUC = {pr_auc:0.2f})', color=pl.cm.viridis(i*(1/len(y_trues))))
    
    baseline = y_trues[i].sum()/len(y_trues[i])

    interp_prec = np.interp(mean_recall, rec, prec)
    interp_prec[0] = 0.0
    precs.append(interp_prec)
    aucs.append(pr_auc)
    
# y_trues = np.concatenate(y_trues, dtype=int)
# y_preds = np.concatenate(y_preds, dtype=float)
# prec, rec, _ = precision_recall_curve(y_trues, y_preds)
# pr_auc = average_precision_score(y_trues, y_preds)

ax.plot([0, 1], [baseline, baseline], '--', label="Chance", alpha=0.8, color="gray", lw=1)

ax.set(
    xlim=[-0.05, 1.05],
    ylim=[-0.05, 1.05],
    # title=f"PRC for {test_cohorts} (target: {cfg.target})",
)

ax.set_xlabel('Recall')
ax.set_ylabel('Precision')

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

ax.legend(loc="lower left")
fig.savefig('/prc_SEM5000.pdf', bbox_inches = 'tight', pad_inches = 1)


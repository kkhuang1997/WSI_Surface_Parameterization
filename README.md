# WSI_Surface_Parameterization

To improve patient stratification and therapeutic response of colorectal cancer, computational pathology has enabled clinical-grade decision makings, for example, MSI prediction and CMS classification. Prior models and training settings have been largely based on natural image domain, which differs from histopathology data. To mitigate the inductive bias, we introduced surface parameterization, a geometric mapping from the surface to a suitable domain, to transform whole slide images into fix-sized squares using conformal energy minimization (CEM) and stretch energy minimization (SEM) algorithms. These transformations are tissue-perceptive by enhancing the region of interest, e.g., cancerous areas, to improve model performance. We validated the transformation at patch-level classification and multiomics prediction tasks, and found that it can beat the original slides of AUROC in a data-efficient manner. For instance, the AUROC of MSI prediction was 0.87 for CEM and SEM with reduced training set, surpassing the original slides of 0.70. To achieve real-world clinical translation, we also recruited 17 CRC patients and predicted their CMS calls using the transformation. The concordance with expression-based classifier could reach up to 47.1% for CEM and 41.2% for SEM, surpassing the original slides of 29.4%. As a proof-of-concept, we also cultured patient-derived organoids to infer relationship between the CMS and organoid morphologies. We assessed the morphological subtypes, i.e., cystic and solid organoids, via image-based profiling and assigned them to CMS classification, with more cystic organoids preferring CMS3 subtype. This organoid phenotypic feature may be integrated into CMS and improve the tissue differentiation evaluation. Overall, our method has provided new shed on the data processing of computational pathology and been proved the SOTA performance at multiomics prediction.

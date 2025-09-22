# Hospital Price Transparency — Business Analytics & ML

A portfolio‑grade project that converts raw hospital price transparency files into **business insights** for pricing strategy, payer negotiations, and market segmentation. The end‑to‑end workflow covers **scalable cleaning**, **feature engineering**, **exploratory analysis**, **predictive modeling**, **clustering**, and **association rule mining**—all presented in a decision‑oriented way.

> **Dataset**: Kaggle — *Transparency in Hospital Prices* (by jpmiller). See the dataset page for terms and license.

---

## Executive Summary

- **Scope & scale**: After cleaning and feature engineering, the modeling matrix contains **227,708 records** and **12,255 columns** (wide one‑hot features and derived fields). The dataset spans **1,562 unique hospitals**, **1,085 cities**, and **44 states**.  
- **Variation & drivers**: Price distribution varies materially by **procedure code**, **payer**, and **location**. The **top‑count codes** are `code_Other` (68,376), `code_NONE` (53,560), `code_C1713` (12,591), `code_27200005` (4,736), and `code_C1776` (2,798).  
- **Price levels (log‑scale medians)**: Most expensive by median (log price): `code_C1776` (≈ **$2,095**), `code_CPT_HCPC_0C1713` (≈ **$1,044**), `code_C1713` (≈ **$686**), `code_C1725` (≈ **$530**), `code_Other` (≈ **$247**).  
- **Setting differences**: Median **inpatient** price (log) ≈ 5.43 (**~$228**); median **outpatient** (log) ≈ 6.31 (**~$550**).  
- **Predictive modeling (demo target: coding status)**:  
  - **Bernoulli Naïve Bayes**: **Accuracy 0.927** (10% sample; strong lift over majority baseline of **~0.554**).  
  - **Decision Tree**: **Accuracy 0.815**, **ROC‑AUC 0.867**, **PR‑AUC 0.873**, minority‑class **F1 0.762**; 5‑fold CV ROC‑AUC **0.863 (±0.009)**, F1 **0.766 (±0.007)**.  
  - **SVM (RBF, class‑balanced)**: **Accuracy ~0.778** (best SVM in the comparison).  
- **Segmentation**:  
  - **K‑Means (k=4)** selected by validation (**Silhouette 0.451**, **Calinski–Harabasz 27,968**, **Davies–Bouldin 0.852**). Cluster sizes: **41.4%**, **32.7%**, **21.3%**, **4.6%**.  
  - **HDBSCAN** reveals micro‑structure (**284 clusters**, **26.8% noise**), indicating nuanced sub‑markets within the four broad segments.  
- **Association rules (pattern mining)**:  
  - Bootstrap mining yields **227 robust rules**.  
  - 5‑fold cross‑validation finds **157 unique rules**, with **71** recurring in all folds (**45.2%** stability).  
  - Location‑anchored patterns recur in **NEW_ALBANY, AUSTIN, ALBUQUERQUE, CHICAGO** and states **IN, NM, IL, KY**—useful for **localized bundles** and **regional playbooks**.

---

## Business Problem & Why It Matters

Hospitals and payers negotiate thousands of prices across procedures. This heterogeneity obscures basic questions like:

- *Where are our prices out of market vs. competitive?*  
- *Which payer–procedure combinations drive margin variability?*  
- *How should we segment facilities for differentiated offers or outreach?*

This repository shows a **repeatable analytics pipeline** that:

- **Benchmarks price posture** by **procedure × payer × geography**.  
- **Flags high‑risk cases** (e.g., coding status likely to create reimbursement friction).  
- **Segments facilities** into actionable groups for **pricing, contracting, and GTM**.  
- **Surfaces stable patterns** that inform **bundles**, **discount ladders**, and **regional strategies**.

---

## Analytics Workflow (What Happens in the Notebook)

1. **Ingestion & Scaling**  
   - Read CSV → convert to **Parquet**; use **Dask** to parallelize operations on large files.  
   - Coerce data types, standardize categorical fields (payer, code, geography), and normalize numeric features.

2. **Cleaning & Feature Engineering**  
   - Remove/leakage‑proof **unique IDs** (e.g., `cms_certification_num`) from model features.  
   - One‑hot encode **codes, payers, states, settings**; engineer **log price** and **size proxies** (e.g., scaled beds).  
   - Prune near‑constant and highly correlated features; impute missing values where appropriate.

3. **Exploratory Data Analysis (EDA)**  
   - Price distributions by **payer** and **setting**; top procedures by **count** and **median price**.  
   - Geographic distribution (cities, states) and concentration (largest hospital = **~1.6%** of records).  
   - Visuals: histograms, box/violin plots, correlation heatmaps to narrate **drivers of variance**.

4. **Predictive Modeling (Demo)**  
   - Target (for demonstration): `inpatient_outpatient_UNSPECIFIED` vs. other—proxy for cases prone to **administrative friction**.  
   - Compare **Bernoulli/Gaussian NB**, **Decision Tree**, and **SVM** with proper train/test split, metrics, and CV.  
   - Report **accuracy, ROC/PR curves, confusion matrix, F1** (class‑specific).  
   - **Business framing**: The same pipeline can be pointed at business labels like **“above‑market price”**, **“payer high‑risk”**, or **“routing class”** for pre‑auth workflows.

5. **Unsupervised Learning**  
   - **K‑Means** (k chosen via Silhouette/CH/DB), **PCA** for interpretation, per‑cluster statistics.  
   - **HDBSCAN** to detect **micro‑clusters** and **noise**, revealing sub‑segments beyond K‑Means.  
   - Business narratives for segments (e.g., value‑oriented vs. premium posture, enterprise systems).

6. **Association Rules (Apriori)**  
   - Transform wide binary features into **transactional views**.  
   - Bootstrap + cross‑validation to identify **stable rules** (support/confidence/lift) and **location‑specific patterns**.  
   - Use cases: **localized bundles**, **payer‑procedure targeting**, **territory planning**.

---

## Key Results (Selected)

- **Top 10 procedures by count**:  
  `code_Other` (68,376), `code_NONE` (53,560), `code_C1713` (12,591), `code_27200005` (4,736), `code_C1776` (2,798) …  
- **Top by median (log price)** with ≈$ conversion:  
  `code_C1776` (**$2,095**), `code_CPT_HCPC_0C1713` (**$1,044**), `code_C1713` (**$686**), `code_C1725` (**$530**), `code_Other` (**$247**).  
- **Setting medians**: Inpatient ≈ **$228**, Outpatient ≈ **$550**.  
- **Classification** (demo target):  
  - Bernoulli NB **accuracy 0.927** (baseline **~0.554**).  
  - Decision Tree **accuracy 0.815**, **ROC‑AUC 0.867**, **PR‑AUC 0.873**; minority‑class **F1 0.762**; CV ROC‑AUC **0.863 ± 0.009**.  
  - Best SVM (RBF, balanced) **accuracy ~0.778**.  
- **Clustering**: K‑Means (k=4) with **Silhouette 0.451**; HDBSCAN **284 micro‑clusters**, **26.8% noise** → heterogeneous sub‑markets.  
- **Rules**: **227** robust (bootstrap); **157** unique across CV, **71** (45.2%) persist across all folds. Prominent locales: **NEW_ALBANY, AUSTIN, ALBUQUERQUE, CHICAGO**; states **IN, NM, IL, KY**.

> *All figures and tables appear inline in the notebook.*

---

## How to Interpret & Reuse the Outputs

- **EDA visuals**: Use to explain **price dispersion** and **drivers** (payer, code, setting, location) to non‑technical stakeholders.  
- **Classification artifacts**: Confusion matrix + ROC/PR show trade‑offs between false positives/negatives; adapt the target to operational labels (e.g., **over‑market flag**, **routing class**) to **prioritize reviews** and **reduce denials**.  
- **Segmentation tables**: Cluster summaries (share, price posture, size proxies, setting mix) support **offer design**, **discount ladders**, and **field playbooks**.  
- **Association rules**: High‑confidence, stable **(payer × procedure × location)** combinations recommend **bundle candidates** and **regional focus**.  
- **Data hand‑off**: Intermediate tables and labels (e.g., cluster assignments) can be exported to **Tableau/Power BI** or used to seed downstream **pricing engines**.

---

## Repository Structure

```
hospital-price-transparency/
├─ notebooks/
│  └─ healthcare_transparency.ipynb   # End-to-end narrative: data→EDA→models→segments→rules
├─ data/
│  ├─ README.md                       # Notes on dataset placement and structure
│  └─ processed/
│     ├─ hospital_data_clean_csv.7z   # Compressed cleaned CSV artifact(s)
│     └─ hospital_data_clean_parquet.7z
├─ scripts/
│  ├─ download_data.sh                # (Optional) dataset automation
│  └─ setup_env.sh                    # (Optional) environment automation
├─ environment.yml                    # Conda environment (Python 3.11 + libs)
├─ requirements.txt                   # Pip alternative
├─ LICENSE                            # MIT (code)
└─ README.md
```

**What each area contains**

- **`notebooks/`** — the full analysis with narrative, code, and plots.  
- **`data/`** — placeholders and guidance for raw data; `processed/` includes compressed outputs to reproduce key steps quickly.  
- **`scripts/`** — optional helpers to automate routine tasks (data download, environment setup).  
- **`environment.yml` / `requirements.txt`** — dependency specifications for consistent execution.  

---

## Data Governance & Reproducibility

- **Public pricing data; no PHI.** Follow the Kaggle dataset license and your organization’s data governance policies.  
- **Leakage prevention**: Unique IDs (e.g., `cms_certification_num`) and high‑uniqueness fields are excluded from model features.  
- **Determinism**: Fixed seeds for sampling and modeling where applicable.  
- **Scalability**: Dask + Parquet for large‑file processing; wide, sparse matrices are handled efficiently.

---

## Acknowledgments

- Dataset: *Transparency in Hospital Prices* (Kaggle) by **jpmiller**.  
- Faculty guidance and feedback acknowledged in notebook header.

---

## About the Author

**Dante Shoghanian** — MSBA candidate focused on **healthcare analytics**. I build scalable analytics pipelines and translate modeling outputs into **clear, high‑leverage decisions** for pricing, contracting, and operations.

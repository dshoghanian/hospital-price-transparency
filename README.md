# Hospital Price Transparency — Business Analytics & ML

![Python](https://img.shields.io/badge/python-3.11-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Status](https://img.shields.io/badge/type-research%2Feducational-orange.svg)

Converts raw U.S. hospital price-transparency files into **business insights** for pricing strategy, payer negotiations, and market segmentation. The end-to-end workflow covers **scalable cleaning**, **feature engineering**, **exploratory analysis**, **predictive modeling**, **clustering**, and **association-rule mining** — all framed for decision-making.

> **Dataset:** Kaggle — *Transparency in Hospital Prices* (by jpmiller). See the [dataset page](https://www.kaggle.com/datasets/jpmiller/healthcare) for terms and license.

---

## Table of Contents

- [Executive Summary](#executive-summary)
- [Business Problem](#business-problem)
- [Dataset](#dataset)
- [Quick Start](#quick-start)
- [Analytics Workflow](#analytics-workflow)
- [Models at a Glance](#models-at-a-glance)
- [Key Results](#key-results)
- [Repository Structure](#repository-structure)
- [Reproducibility & Limitations](#reproducibility--limitations)
- [Data Governance](#data-governance)
- [License & Acknowledgments](#license--acknowledgments)

---

## Executive Summary

- **Scope & scale:** After cleaning and feature engineering the modeling matrix is **227,708 records × 12,255 columns** (wide one-hot features plus derived fields), spanning **1,562 hospitals**, **1,085 cities**, and **44 states**.
- **Price drivers:** Price varies materially by **procedure code**, **payer**, and **location**. No single feature dominates — pricing is driven by many weak signals, which is why multi-variable models are needed.
- **Setting differences:** Median **outpatient** price (log ≈ 6.31, ~\$550) exceeds median **inpatient** price (log ≈ 5.43, ~\$228); inpatient prices are more variable.
- **Classification (demo target — `inpatient_outpatient_UNSPECIFIED`):**
  - **Bernoulli Naïve Bayes:** accuracy **0.869**, ROC-AUC **0.957** (10% sample, 500 chi2-selected features) vs. a majority baseline of **~0.554**.
  - **Decision Tree:** accuracy **0.815**, ROC-AUC **0.867**, PR-AUC **0.873**, minority-class F1 **0.762**; 5-fold CV ROC-AUC **0.863 (±0.009)**.
  - **SVM (RBF, class-balanced):** accuracy **~0.778**; addressing class imbalance mattered more than kernel choice.
- **Segmentation:** **K-Means (k=4)** selected by validation (Silhouette **0.451**, Calinski-Harabasz **27,968**, Davies-Bouldin **0.852**). **HDBSCAN** reveals **284 micro-clusters** with **26.8% noise**, and a hierarchical dendrogram independently supports four broad segments.
- **Association rules:** Bootstrap mining yields **227 robust rules**; 5-fold CV finds **156 unique rules**, with **72 (46.2%)** recurring in every fold. Location-anchored patterns concentrate in **Kentucky** (Louisville, Lexington, Paducah).

---

## Business Problem

Hospitals and payers negotiate thousands of prices across procedures. This heterogeneity obscures basic questions:

- *Where are our prices out of market vs. competitive?*
- *Which payer–procedure combinations drive margin variability?*
- *How should we segment facilities for differentiated offers or outreach?*

This repository demonstrates a **repeatable analytics pipeline** that benchmarks price posture by procedure × payer × geography, flags high-risk cases (e.g., coding status likely to create reimbursement friction), segments facilities into actionable groups, and surfaces stable patterns for bundles, discount ladders, and regional strategies.

---

## Dataset

| | Raw (Kaggle) | Cleaned (this repo) |
|---|---|---|
| `hospital_prices.csv` | ~300M price records, **27.4 GB** | — |
| `hospitals.csv` | 1,800+ hospitals, **847 KB** | — |
| `hospital_data_clean.parquet` | — | **227,708 × 12,255** (shipped compressed in `data/processed/`) |

**Key raw fields** (`hospital_prices.csv`): `cms_certification_num` (hospital ID), `payer` (insurer / CASH PRICE / GROSS CHARGE / MIN / MAX), `code` (CPT/HCPCS/DRG), `description`, `inpatient_outpatient`, `price`. Hospital metadata (state, city, beds, ZIP) is joined from `hospitals.csv`.

---

## Quick Start

### 1. Environment

```bash
# Option A — automated
bash scripts/setup_env.sh

# Option B — manual
conda env create -f environment.yml      # env: healthcare_env (Python 3.11)
conda activate healthcare_env
python -m ipykernel install --user --name=healthcare_env --display-name "Python (healthcare_env)"
```

A pip-only path is also available: `pip install -r requirements.txt`.

### 2. Data — pick one

**Fast path (recommended):** use the cleaned artifact shipped in this repo, so you can skip the 27 GB download and run EDA/modeling directly.

```bash
# Requires 7-Zip (macOS: brew install p7zip)
7z x data/processed/hospital_data_clean_parquet.7z -onotebooks/
# -> produces notebooks/hospital_data_clean.parquet
```

The modeling and EDA cells load `hospital_data_clean.parquet` from the notebook's working directory, so place it next to the notebook (i.e. in `notebooks/`).

**Full path (reproduce from scratch):** download the raw dataset and re-run the preprocessing cells (Kaggle API token required at `~/.kaggle/kaggle.json`):

```bash
bash scripts/download_data.sh   # downloads & unzips hospitals.csv + hospital_prices.csv into data/
```

> ⚠️ The first preprocessing cells (CSV → Parquet conversion) contain **machine-specific absolute paths** from the original author's environment. Update `dataset_path` in those cells to point at your local `data/` before running the full path. See [Reproducibility & Limitations](#reproducibility--limitations).

### 3. Run

```bash
jupyter lab     # open notebooks/healthcare_transparency.ipynb and run top-to-bottom
```

---

## Analytics Workflow

1. **Ingestion & scaling** — CSV → Parquet; **Dask** (40 partitions, Snappy compression) parallelizes the 27 GB price file.
2. **Cleaning & feature engineering** — median-impute price, IQR outlier removal, log-transform price, drop non-predictive columns, one-hot encode `code`/`payer`/`state`/`inpatient_outpatient`, scale `beds`, and **stratified-sample by state** to preserve geographic balance.
3. **EDA** — price distributions by payer/setting, top procedures by count and median, geographic and bed-size patterns, correlation heatmaps.
4. **Supervised modeling** — Naïve Bayes, Decision Tree, and SVM on `inpatient_outpatient_UNSPECIFIED`, with train/test splits, 5-fold CV, ROC/PR curves, and cost-weighted error analysis.
5. **Unsupervised** — K-Means (k chosen via Silhouette/CH/DB) + PCA, HDBSCAN for micro-structure, and Agglomerative (hierarchical) clustering with a dendrogram for cross-validation.
6. **Association rules** — Apriori (MLxtend) over a transactional view, with bootstrap + cross-validation to keep only **stable** rules.

---

## Models at a Glance

| Technique | Library | Task | Headline metric |
|---|---|---|---|
| Bernoulli / Gaussian Naïve Bayes | scikit-learn | Classification | Accuracy **0.869** |
| Decision Tree (CART, depth 5) | scikit-learn | Classification | ROC-AUC **0.867** |
| SVM (Linear & RBF, balanced) | scikit-learn | Classification | Accuracy **~0.778** |
| K-Means (k=4) | scikit-learn | Segmentation | Silhouette **0.451** |
| HDBSCAN | hdbscan | Density clustering | **284** clusters, 26.8% noise |
| Agglomerative + dendrogram | scikit-learn / SciPy | Hierarchical clustering | Confirms 4 segments |
| Apriori association rules | MLxtend | Pattern mining | **72** rules stable across all CV folds |

---

## Key Results

> **Reading the procedure codes.** The `code` field uses [HCPCS Level II](https://www.cms.gov/medicare/coding-billing/healthcare-common-procedure-system) codes — the "C-codes" below are implantable-device categories billed under Medicare's hospital outpatient system. Two labels are data-cleaning buckets, not real procedures: **`code_NONE`** = records with no procedure code, and **`code_Other`** = many low-frequency codes collapsed into one catch-all during cleaning.

**Most common (by record count)**

| Code | What it is | Count |
|---|---|---|
| `code_Other` | Catch-all bucket (many rare codes combined) | 68,376 |
| `code_NONE` | No procedure code recorded | 53,560 |
| `code_C1713` | Anchor/screw for bone-to-bone or soft-tissue-to-bone (orthopedic implant) | 12,591 |
| `code_27200005` | Non-standard / hospital-local code (not a valid CPT/HCPCS format) | 4,736 |
| `code_C1776` | Implantable joint device (e.g., artificial joint) | 2,798 |

**Most expensive (by median price; log values converted to ≈\$)**

| Code | What it is | Median price |
|---|---|---|
| `code_C1776` | Implantable joint device | ~\$2,095 |
| `code_CPT_HCPC_0C1713` | Encoding variant of C1713 (bone anchor/screw implant) | ~\$1,044 |
| `code_C1713` | Bone anchor/screw implant | ~\$686 |
| `code_C1725` | Transluminal angioplasty catheter (opens narrowed blood vessels) | ~\$530 |
| `code_Other` | Catch-all bucket | ~\$247 |

Implantable devices (joints, anchors) sit at the top of the price range — consistent with specialized, high-cost surgical supplies.

- **Setting medians:** inpatient ≈ \$228, outpatient ≈ \$550.
- **Decision Tree** identifies coding practices (`code_Other`), geography (`state_FL`, `KY`), payer, and facility size as the strongest predictors.
- **Segments:** four market tiers — value-oriented small facilities, two premium standard tiers, and large enterprise systems — each with distinct go-to-market implications.

---

## Repository Structure

```
hospital-price-transparency/
├─ notebooks/
│  └─ healthcare_transparency.ipynb       # End-to-end narrative: data → EDA → models → segments → rules
├─ data/
│  ├─ README.md                           # Dataset placement + decompression notes
│  └─ processed/
│     ├─ hospital_data_clean_csv.7z       # Compressed cleaned CSV
│     └─ hospital_data_clean_parquet.7z   # Compressed cleaned Parquet (used by the notebook)
├─ scripts/
│  ├─ download_data.sh                     # Kaggle download + unzip
│  └─ setup_env.sh                         # Conda env + Jupyter kernel
├─ environment.yml                         # Conda environment (Python 3.11)
├─ requirements.txt                        # Pip alternative
├─ LICENSE                                 # MIT (code)
└─ README.md
```

Raw `data/*.csv` files are **not committed** (too large; download via script). Only the compressed cleaned artifacts ship in `data/processed/`.

---

## Reproducibility & Limitations

- **Determinism:** fixed `random_state=42` for sampling and modeling throughout.
- **Sampling:** classifiers train on stratified samples for tractability — Naïve Bayes 10%, Decision Tree 5%, SVM 2%; clustering uses 20%. Metrics reflect those samples.
- **Leakage prevention:** unique IDs (e.g., `cms_certification_num`) and other high-uniqueness fields are present in the data but **excluded from model features** via the feature-selection step.
- **Naïve Bayes feature selection (fixed & re-run):** an earlier version hit a bug — `SelectKBest(chi2)` rejects the negative values in `beds_scaled`, and a bare `except` silently fell back to training on *all* ~12k features (which is what produced the inflated **0.927** seen in older versions). The chi2 step is now corrected (inputs are min-max scaled to [0, 1] and the masking `except` removed), so feature selection actually runs and keeps the top **500** features. The notebook has been re-executed with the fix: Bernoulli NB now scores **0.869** accuracy / **0.957** ROC-AUC — a slightly lower but honest result from a properly selected feature set.
- **SVM feature selection:** the `f_classif` selector emits warnings on constant one-hot columns (producing NaN scores for those columns); selection still completes and the model trains, but the selected set can be mildly degraded.
- **Saved outputs are from a multi-session run:** notebook execution counts reset per section, so the committed outputs were produced section-by-section across kernel restarts rather than one clean top-to-bottom pass. They were also generated under Python 3.12 / the `base` conda env, not the documented `healthcare_env` (Python 3.11) — re-run end-to-end in `healthcare_env` for a clean, reproducible pass.
- **Preprocessing cells are environment-specific:** the CSV→Parquet conversion cells use absolute Windows paths (`C:\Users\...`) from the original author's machine and expect the full 27 GB raw file. They are kept for transparency; the cleaning logic is described narratively rather than as a fully portable script. **To reproduce from raw data, edit those paths first.** For most users the shipped cleaned artifact (see [Quick Start](#quick-start)) is the intended entry point.
- **Scope:** this is a research/educational project (originally a graduate coursework analysis). There is no test suite, and the demo classification target (`inpatient_outpatient_UNSPECIFIED`) is a stand-in — point the same pipeline at business labels such as "above-market price" or "payer high-risk" to operationalize it.

---

## Data Governance

- **Public pricing data; no PHI.** Follow the Kaggle dataset license and your organization's data-governance policies.
- High-uniqueness identifiers are excluded from model features to prevent leakage.
- Dask + Parquet handle the large, wide, sparse matrices efficiently.

---

## License & Acknowledgments

- **Code:** MIT (see `LICENSE`).
- **Dataset:** *Transparency in Hospital Prices* (Kaggle) by **jpmiller**, under its own terms.

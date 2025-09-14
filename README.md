# Hospital Price Transparency — Analysis & ML
### By: Dante Shoghanian

Reproducible repo scaffolding for analyzing the **Transparency in Hospital Prices** dataset and training baseline ML models (Naïve Bayes, Decision Trees, SVM, Association Rules, K-Means, HDBSCAN).  
Primary notebook: `notebooks/healthcare_transparency.ipynb`.

> **Data source**: Kaggle dataset *Transparency in Hospital Prices* by jpmiller. See dataset page for details and license.  
> Link: https://www.kaggle.com/datasets/jpmiller/healthcare

---

## Repo layout

```
hospital-price-transparency/
├── .gitattributes
├── .gitignore
├── LICENSE
├── README.md
├── environment.yml
├── requirements.txt
├── data/
│   ├── README.md
│   ├── .gitkeep
│   └── processed/
│       └── .gitkeep
├── notebooks/
│   └── healthcare_transparency.ipynb
└── scripts/
    ├── download_data.sh
    └── setup_env.sh
```

- **`data/`**: Place raw CSVs from Kaggle here (`hospitals.csv`, `hospital_prices.csv`).  
  Put your cleaned files here as well: `processed/hospital_data_clean.csv` and `processed/hospital_data_clean.parquet`.
- **`notebooks/`**: Your analysis notebook.
- **`scripts/`**: Convenience scripts for environment setup and data download.
- **`environment.yml`**: Conda environment spec (name: `healthcare_env`).
- **`requirements.txt`**: Optional pip fallback.

---

## Quickstart

### 1) Create the Conda environment
```bash
conda env create -f environment.yml
conda activate healthcare_env
python -m ipykernel install --user --name=healthcare_env --display-name "Python (healthcare_env)"
```

### 2) Download data from Kaggle
> You need a Kaggle account and an API token (`kaggle.json`). In Kaggle **Account** → **API** → *Create New Token*, then place `kaggle.json` at `~/.kaggle/kaggle.json` (Linux/Mac) or `%USERPROFILE%\.kaggle\kaggle.json` (Windows).

To pull the original files into `data/`:
```bash
bash scripts/download_data.sh
```
This will (a) download the dataset archive and (b) place `hospitals.csv` and `hospital_prices.csv` under `data/`.

### 3) Add your cleaned files (if you already have them)
Place your derived files here:
```
data/processed/hospital_data_clean.csv
data/processed/hospital_data_clean.parquet
```

### 4) Run the notebook
```bash
jupyter lab
# Open notebooks/healthcare_transparency.ipynb and select the "Python (healthcare_env)" kernel
```

---

## Data dictionary (from the notebook)

### `hospital_prices.csv`
- **cms_certification_num** — Unique identifier linking hospitals to price records  
- **payer** — Type of insurance company (e.g., CASH PRICE, GROSS CHARGE, MIN, MAX, or insurer name)  
- **code** — Medical procedure code (e.g., CPT, HCPCS, DRG)  
- **internal_revenue_code** — Hospital’s internal billing code  
- **units** — Quantity of service (e.g., “1 unit”, “2 ccs”)  
- **description** — Description of the medical procedure  
- **inpatient_outpatient** — Inpatient/Outpatient/Both/Unspecified  
- **price** — Charge associated with the payer and procedure  
- **code_disambiguator** — Used to avoid duplicate procedure codes  

### `hospitals.csv`
- **cms_certification_num** — Unique identifier linking hospitals to price records  
- **name** — Hospital name  
- **address** — Hospital street address  
- **city** — City  
- **state** — State  
- **zip5** — 5-digit ZIP code  
- **beds** — Number of hospital beds  
- **phone_number** — Contact number  
- **homepage_url** — Hospital website  
- **chargemaster_url** — URL for pricing information  
- **last_edited_by_username** — Last editing user  

> The cleaned file `hospital_data_clean.csv` / `hospital_data_clean.parquet` merges and filters columns from the two sources and applies feature engineering for modeling. See the notebook for steps and rationale.

---

## Reproducibility checklist

- Environment is fully specified in `environment.yml` (**healthcare_env**).  
- Raw data are pulled from Kaggle via `scripts/download_data.sh`.  
- Cleaned data artifacts live under `data/processed/`.  
- Notebook records exploratory analysis and models (Naïve Bayes, Decision Trees, SVM, Association Rules, KMeans, HDBSCAN).

---

## GitHub: initialize & push

After you create an empty repo on GitHub, run these in the project root:

```bash
git init
git add .
git commit -m "Initial commit: hospital price transparency analysis"
git branch -M main
git remote add origin git@github.com:<YOUR_GITHUB_USERNAME>/hospital-price-transparency.git
git push -u origin main
```

---

## Notes on data licensing

Check the dataset page on Kaggle for its license. If redistribution is restricted, **don’t** commit the CSVs or Parquet files—use the download script instead. You can safely version-control your **code** and **notebooks**.

---

## Acknowledgments

- Dataset: *Transparency in Hospital Prices* (Kaggle) by jpmiller.

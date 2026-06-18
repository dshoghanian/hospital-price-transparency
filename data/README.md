# Data directory

This folder holds the dataset. Raw CSVs are **not committed** (too large). The cleaned, derived artifacts ship here in compressed form under `processed/`.

## What's included

```
data/
├─ README.md
└─ processed/
   ├─ hospital_data_clean_csv.7z       # Cleaned dataset, CSV
   └─ hospital_data_clean_parquet.7z   # Cleaned dataset, Parquet (used by the notebook)
```

## Using the cleaned artifact (recommended)

The notebook loads `hospital_data_clean.parquet` from its own working directory, so extract it next to the notebook:

```bash
# Requires 7-Zip (macOS: brew install p7zip)
7z x processed/hospital_data_clean_parquet.7z -o../notebooks/
# -> ../notebooks/hospital_data_clean.parquet
```

## Downloading the raw dataset (only needed to reproduce from scratch)

Raw files from the Kaggle dataset *Transparency in Hospital Prices*:

- `hospitals.csv`
- `hospital_prices.csv`

```bash
# Make sure your Kaggle token is configured at ~/.kaggle/kaggle.json
# See: https://www.kaggle.com/docs/api

# Download the full dataset zip into data/
kaggle datasets download -d jpmiller/healthcare -p . -w

# Unzip (Linux/Mac)
unzip healthcare.zip -d .

# Windows (PowerShell)
Expand-Archive -Path healthcare.zip -DestinationPath .
```

> If you only need specific files, request them individually:
```bash
kaggle datasets download -d jpmiller/healthcare -f hospitals.csv -p . -w
kaggle datasets download -d jpmiller/healthcare -f hospital_prices.csv -p . -w
```

> Note: the notebook's CSV→Parquet preprocessing cells use machine-specific absolute paths from the original author's environment — update them to point at this folder before re-running the full pipeline.

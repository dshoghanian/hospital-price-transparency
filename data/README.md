# Data directory

- Place raw files from the Kaggle dataset *Transparency in Hospital Prices* here:
  - `hospitals.csv`
  - `hospital_prices.csv`

- Place cleaned/derived artifacts here:
  - `processed/hospital_data_clean.csv`
  - `processed/hospital_data_clean.parquet`

## Downloading with the Kaggle CLI

```bash
# Make sure your Kaggle token is configured at ~/.kaggle/kaggle.json
# See: https://www.kaggle.com/docs/api

# Download the full dataset zip to data/
kaggle datasets download -d jpmiller/healthcare -p data/ -w

# Unzip (Linux/Mac)
unzip data/healthcare.zip -d data/

# Windows (PowerShell)
Expand-Archive -Path data/healthcare.zip -DestinationPath data/
```

> If you only need specific files, you can request them individually:
```bash
kaggle datasets download -d jpmiller/healthcare -f hospitals.csv -p data/ -w
kaggle datasets download -d jpmiller/healthcare -f hospital_prices.csv -p data/ -w
```
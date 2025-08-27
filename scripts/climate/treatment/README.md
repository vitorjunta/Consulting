# Climate Data Treatment

This folder contains scripts for **climate data preprocessing and cleaning**.  
The scripts are designed to standardize and prepare raw outputs from **HOBO dataloggers** for further analysis.

---

## 📄 Script available

- **climate_treatment.R**  
  Main script for treating climate data.  

### 🔹 What it does
1. Reads raw climate data exported from **HOBO dataloggers** (CSV, XLSX, or TXT).
2. Cleans and formats date and time columns.
3. Renames variables for consistency (e.g., `Tint`, `Text`, `Uint`, `Uext`).
4. Exclude days when the device was handled (e.g., first and last day).
5. Input data on days with 23 records.
6. Exclude days with 22 or less records.
7. Exports the cleaned dataset for analysis.

---

## ⚙️ Requirements

The script was developed in **R**.  
Required packages:
- `dplyr`
- `readr`
- `lubridate`
- (others depending on your dataset)

---

## 🚀 How to use

1. Export your raw data from the **HOBO datalogger** using HOBOware or HOBOlink.  
2. Place the exported file in a working directory.  
3. Open `climate_treatment.R` in R or RStudio.  
4. Edit the file path inside the script to match your dataset.  
5. Run the script.  
6. The cleaned file will be saved in the specified output path.  

---

## 📌 Notes

- All explanations inside the script are written in **uppercase (ENGLISH)** for clarity.  
- This script is meant for **data preprocessing only**; further analysis should be done in separate scripts.

---



# 🏠 Housing Data Cleaning with SQL

A real-world SQL data cleaning project on a messy Kaggle housing dataset (400+ rows), performed entirely with **MySQL**. This project focuses on identifying and fixing common real-world data quality issues — the kind every backend/data role deals with before data is analysis-ready.

## 📌 Dataset

A synthetic housing dataset with the following columns:
`area_sqft`, `bedrooms`, `bathrooms`, `year_built`, `price`, `location`

The raw CSV contained multiple layers of intentional messiness — a great case study for practicing SQL-based data cleaning.

## 🔍 Issues Identified & Fixed

### 1. Disguised missing values
`price`, `year_built`, and `bedrooms` had missing data represented three different ways: empty strings, `'N/A'`, and `'unavailable'`. Converted all to proper SQL `NULL`.

```sql
UPDATE HOUSE_1
SET price = NULL
WHERE TRIM(price) IN ('N/A', 'unavailable', '');
```

### 2. Inconsistent text formatting (`location` column)
The same city appeared in up to **10 different forms** — mixed casing (`Austin`, `AUSTIN`), trailing whitespace (`Austin `), and abbreviations (`l.a.`, `LA`, `sf`, `nyc`).

**Step 1 — Normalize case & whitespace:**
```sql
UPDATE HOUSE_1
SET location = LOWER(TRIM(location));
```

**Step 2 — Map abbreviations and typos to standard names:**
```sql
UPDATE HOUSE_1
SET location = CASE
    WHEN location IN ('la', 'l.a.', 'los angeles') THEN 'los angeles'
    WHEN location IN ('sf') THEN 'san francisco'
    WHEN location IN ('nyc') THEN 'new york city'
    WHEN location IN ('chicgo') THEN 'chicago'
    WHEN location IN ('bostan') THEN 'boston'
    ELSE location
END;
```
Result: 24 distinct location values reduced to **7 clean, standardized city names**.

### 3. Logically invalid values
- `area_sqft` had negative values (e.g. `-100`), which is physically impossible.
- `bedrooms` had a value of `20`, a clear outlier against the dataset's normal 1–6 range.

```sql
UPDATE HOUSE_1 SET area_sqft = NULL WHERE area_sqft < 0;
UPDATE HOUSE_1 SET bedrooms = NULL WHERE bedrooms = 20;
```

### 4. Corrupted price values (pattern detection)
Some prices looked far too low or too high compared to similar houses. Rather than guessing, a **price-per-square-foot ratio** was calculated to detect anomalies systematically:

```sql
SELECT area_sqft, price, price / area_sqft AS price_per_sqft
FROM HOUSE_1
WHERE price IS NOT NULL AND area_sqft IS NOT NULL
ORDER BY price_per_sqft DESC;
```

This revealed two exact, repeating multiplier patterns — a strong signal of systematic data corruption rather than random typos:
- A group of rows where `price = area_sqft × 10` (abnormally low)
- A group of rows where `price = area_sqft × 2000` (abnormally high)

Both groups were set to `NULL` rather than guessed at, since the true value couldn't be recovered:
```sql
UPDATE HOUSE_1 SET price = NULL WHERE price = area_sqft * 10;
UPDATE HOUSE_1 SET price = NULL WHERE price = area_sqft * 2000;
```

### 5. Duplicate rows
Used `GROUP BY` + `HAVING COUNT(*) > 1` to detect duplicate rows, then removed them using a `ROW_NUMBER()` window function to keep only the first occurrence of each duplicate group.

Key learning: standard equality-based duplicate removal silently fails on rows containing `NULL`, since `NULL = NULL` evaluates to `UNKNOWN` in SQL rather than `TRUE`. Fixed by adding a surrogate primary key (`id`) and using MySQL's **NULL-safe equality operator (`<=>`)** for the final cleanup pass.

## 🧠 Key Takeaways
- Missing data isn't always represented as `NULL` — it can hide behind placeholder strings.
- Categorical text data needs normalization (case, whitespace, synonyms) before it can be trusted.
- Outliers aren't just "big numbers" — ratios (like price-per-sqft) can reveal *systematic* corruption vs. random noise.
- `NULL` comparison behavior in SQL is a common, easy-to-miss gotcha when deduplicating data.

## 🛠️ Tools
MySQL Workbench

## 📁 Files
- `raw_housing_data.csv` — original messy dataset
- `cleaning_script.sql` — full set of cleaning queries in order

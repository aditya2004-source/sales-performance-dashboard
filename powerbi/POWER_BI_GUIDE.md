# Power BI Dashboard – Build Guide

Data source: `data/superstore_clean.csv` (output of the SQL cleaning step, 9,993 rows).

## 1. Load data
Power BI Desktop → **Get Data → Text/CSV** → `superstore_clean.csv` → **Transform Data**
- Set `order_date`, `ship_date` to **Date**
- Set `sales`, `discount`, `profit` to **Decimal Number**; `quantity` to **Whole Number**
- **Close & Apply**

## 2. Date table (Modeling → New Table)
```DAX
Calendar = ADDCOLUMNS(
    CALENDAR(DATE(2019,1,1), DATE(2022,12,31)),
    "Year", YEAR([Date]),
    "Month", FORMAT([Date], "MMM"),
    "MonthNo", MONTH([Date])
)
```
Relationship: `Calendar[Date]` → `superstore_clean[order_date]` (one-to-many). Sort `Month` by `MonthNo`.

## 3. DAX measures (Modeling → New Measure)
```DAX
Total Sales      = SUM(superstore_clean[sales])
Total Profit     = SUM(superstore_clean[profit])
Profit Margin %  = DIVIDE([Total Profit], [Total Sales])
Total Orders     = DISTINCTCOUNT(superstore_clean[order_id])
Total Customers  = DISTINCTCOUNT(superstore_clean[customer_id])
Avg Order Value  = DIVIDE([Total Sales], [Total Orders])
Sales LY         = CALCULATE([Total Sales], SAMEPERIODLASTYEAR(Calendar[Date]))
Sales Growth %   = DIVIDE([Total Sales] - [Sales LY], [Sales LY])
```
Discount band (New Column):
```DAX
Discount Band =
SWITCH(TRUE(),
    superstore_clean[discount] = 0,    "0%",
    superstore_clean[discount] <= 0.1, "1-10%",
    superstore_clean[discount] <= 0.2, "11-20%",
    superstore_clean[discount] <= 0.3, "21-30%",
    superstore_clean[discount] <= 0.5, "31-50%",
    ">50%")
```

## 4. Dashboard layout (one page)
| Area | Visual | Fields |
|---|---|---|
| Top row | 5 **Cards** | Total Sales, Total Profit, Profit Margin %, Total Orders, Sales Growth % |
| Left middle | **Line chart** | Calendar[Date] (Month) × Total Sales |
| Right middle | **Clustered bar** | region × Total Sales, Total Profit |
| Left bottom | **Bar chart** | sub_category × Total Profit (conditional colour: red if < 0) |
| Right bottom | **Column chart** | Discount Band × Profit Margin % |
| Side panel | **Slicers** | Year, region, category, segment |
| Optional | **Table** | Top 10 products by Total Profit |

## 5. Expected numbers (check your cards match)
| KPI | Value |
|---|---|
| Total Sales | $2,296,919 |
| Total Profit | $286,409 |
| Profit Margin | 12.47% |
| Orders | 5,009 |
| Customers | 793 |

## 6. Save
- Save as `powerbi/Sales_Performance_Dashboard.pbix`
- Export a screenshot as `images/powerbi_dashboard.png`

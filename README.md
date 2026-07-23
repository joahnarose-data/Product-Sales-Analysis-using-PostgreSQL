# Product-Sales-Analysis-Using-PostgreSQL
This project analyzes a multi-channel retail sales dataset using PostgreSQL to generate business insights on sales performance, customer behavior, product performance, discounts, payments, returns, logistics, and negative transactions. It showcases an end-to-end SQL  analytics workflow from data cleaning to executive-level business insights.

# Business Problem
Retail businesses generate thousands of transactions across multiple products, sales channels, payment methods, countries, and
logistics providers. While transactional data containcs valuable business information, organizations often struggle to transform raw 
records into actionable insights.

This project addresses that challenge by analyzing sales transactions to answer practical business questions such as:

- Which products and categories generate the highest revenue?
- How do customers purchase across countries and sales channels?
- Do discounts increase sales performance?
- Which payment methods and shipment providers are most preferred?
- What factors are associated with product returns and negative transactions?
- What operational insights can support better business decisions?

# Objectives
This project aims to:

- Clean and prepare a retail sales dataset using PostgreSQL.
- Perform exploratory SQL analysis across multiple business dimensions.
- Measure sales performance, customer purchasing behavior, and product performance.
- Evaluate the effectiveness of discounts and payment methods.
- Analyze product return patterns and logistics performance.
- Investigate factors associated with negative transactions.
- Product executive-level business insights based on SQL analysis.

# Tools Used
- **Microsoft Excel** — Initial dataset inspection
- **pgAdmin 4** — Database administration and project setup
- **PostgreSQL** — SQL querying and data analysis
- **SQL** — Data cleaning, validation, and business analysis
- **AI** — SQL debugging, query refinement, and technical writing support
- **GitHub** — Project documentation

# Dataset
- Records: 49,782 transactions
- Industry: Retail / E-commerce 
- Data includes:
  - **Products**
      - Backpack, Blue Pen, Desk Lamp, Headphones, Notebook, Office Chair, 
        T-shirt, USB Cable, Wall Clock, White Mug, Wireless Mouse
  - **Categories**
      - Accessories, Apparel, Electronics, Furniture, Stationery
  - **Sales Channels**
      - In-Store & Online
  - **Countries**
      - Australia, Belgium, France, Germany, Italy, Netherlands, Norway, 
        Portugal, Spain, Sweden, United Kingdom, United States
  - **Payment Methods**
      - Bank Transfer, Credit Card, PayPal
  - **Discounts**
      - High Discount, Medium Discount, Low Discount, No Discount
  - **Shipment Providers**
      - DHL, FedEx, Royal Mail, UPS
  - **Warehouse Locations**
      - Amsterdam, Berlin, London, Paris, Rome
  - **Returns**
      - Not Returned, Returned
  - **Order Priority**
      - High, Medium, Low

  # Project Workflow
  ```mermaid
  flowchart TD
      A[Raw Sales Dataset]
      B[Data Cleaning & Preparation]
      C[Data Validation]
      D[Exploratory SQL Analysis]
      E[Business Insights]
      F[Executive-Level Insights]

      A --> B
      B --> C
      C --> D
      D --> E
      E --> F
  ```
  # Repository Structure
  ```text
  product-sales-analysis/
  │
  ├── data/
  │   ├── raw/
  │   │   └── product_sales_raw.csv
  |   │   └── product_sales_raw_backup.csv
  │   └── cleaned/
  │       └── product_sales_clean.csv
  │
  ├── sql/
  │   ├── 01_data_quality_assessment.sql
  │   ├── 02_data_cleaning.sql
  │   ├── 03_sales_performance_analysis.sql
  │   ├── 04_customer_purchasing_behavior_analysis.sql
  │   ├── 05_product_performance_analysis.sql
  │   ├── 06_discount_analysis.sql
  │   ├── 07_payment_analysis.sql
  │   ├── 08_returns_analysis.sql
  │   ├── 09_logistics_and_operations_analysis.sql
  │   ├── 10_negatives_transaction_analysis.sql
  │   └── 11_executive_insights.sql
  │
  ├── README.md
  ```
  # Analysis Sections
  - Data Quality Assessment
  - Data Cleaning
  - Sales Performance Analysis
  - Customer Purchasing Behavior Analysis
  - Product Performance Analysis
  - Discount Analysis
  - Payment Analysis
  - Returns Analysis
  - Logistics and Operations Analysis
  - Negatives Transaction Analysis
  
  # Executive Insights
- **Revenue is primarily driven by sales volume rather than product pricing.** Categories with more product lines, particularly **Furniture** and **Electronics**, consistently generated the highest transaction volume and revenue.

- **Customer purchasing behavior is broadly distributed.** Product demand, sales channel preferences, payment methods, shipment providers, and warehouse usage showed relatively balanced patterns, indicating no single option strongly dominates customer behavior.

- **High discount offerings are associated with higher sales performance.** Higher discounts correspond to greater transaction volume, units sold, and overall revenue. However, discount usage is consistently applied across products and categories, suggesting discount strategy alone does not explain overall product performance.

- **Product returns remain stable across the business.** Approximately **1 in every 10 positive transactions** resulted in a return, with only small differences across products, categories, countries, sales channels, payment methods, shipment providers, discount levels, and order priorities.

- **Negative transactions account for only 5% of all transactions** and represent approximately **2.51% of positive transaction revenue**, indicating a relatively limited financial impact. Most business dimensions exhibit consistently low negative transaction rates, although **High Discount** transactions showed a noticeably higher negative transaction rate and may warrant further investigation.

- **Overall, the business demonstrates balanced operational performance.** Sales, logistics, customer behavior, and product demand remain consistently distributed across multiple business dimensions, suggesting that future optimization efforts may be more effective when focused on pricing strategies, discount policies, customer segmentation, and product assortment rather than large-scale operational changes.

  # SQL Preview
One of the analytical queries from this project combines multiple Common Table Expressions (CTEs), window functions, and ranking logic to evaluate warehouse performance across several business metrics.

```sql
WITH transactions AS(
    SELECT 
        warehouselocation,
        COUNT(*) AS transaction_count,
        DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS tc_rank
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
      AND returnstatus = 'Not Returned'
    GROUP BY warehouselocation
),
quantity AS(
    SELECT
        warehouselocation,
        SUM(quantity) AS quantity_count,
        DENSE_RANK() OVER(ORDER BY SUM(quantity) DESC) AS qc_rank
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
      AND returnstatus = 'Not Returned'
    GROUP BY warehouselocation
),
revenue AS(
    SELECT
        warehouselocation,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
        DENSE_RANK() OVER(
            ORDER BY ROUND(SUM((quantity * unitprice) * (1 - discount)),2) DESC
        ) AS r_rank
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
      AND returnstatus = 'Not Returned'
    GROUP BY warehouselocation
)
SELECT
    t.warehouselocation,
    t.transaction_count,
    t.tc_rank,
    q.quantity_count,
    q.qc_rank,
    r.revenue,
    r.r_rank,
    (t.tc_rank + q.qc_rank + r.r_rank) AS overall_score,
    RANK() OVER(
        ORDER BY (t.tc_rank + q.qc_rank + r.r_rank)
    ) AS overall_rank
FROM transactions t
INNER JOIN quantity q
    ON t.warehouselocation = q.warehouselocation
INNER JOIN revenue r
    ON t.warehouselocation = r.warehouselocation;
```
  # SQL Skills Demonstrated
- CTEs
- Window Functions
- CASE Statements
- Aggregate Functions
- STRING_AGG()
- Date Functions
- Ranking Functions
- Conditional Aggregation
- Business KPI Calculations
- Revenue Analysis
- Return Rate Analysis
- Customer Segmentation
    
  # Future Improvements
- Build an interactive Power BI dashboard
- Perform customer segmentation using RFM Analysis
- Develop sales forecasting models using Python
- Integrate SQL with Tableau/Power BI

# Data Source
- Dataset Title: Online Sales Dataset
- Website: Kaggle
- Author: Yusuf Delikkaya
- Source Link: https://www.kaggle.com/datasets/yusufdelikkaya/online-sales-dataset
- License: CCO: Public Domain
  
# Personal Reflection
Over the past few months, I learned that business analytics is far more than simply writing SQL queries. It requires a combination of 
technical skills, analytical thinking, patience, and a structured approach to data cleaning, validation, and business analysis. Throughout this project, I realized that data cleaning is one of the most critical stages of the analytics process because the quality of 
the analysis ultimately depends on the quality of the data.

As a beginner in SQL, constructing queries was initially challenging. I had to understand not only the syntax but also the logic behind 
each query and how different SQL operations affected the results. To strengthen my skills, I used AI as a debugging assistant and practice partner by solving progressively challenging SQL exercises. This approach significantly improved both my SQL proficiency and my 
confidence in approaching analytical problems.

Coming from a Physics background, I also found it challenging to transition from writing detailed scientific reports to producing 
concise, business-focused analyses. Learning to formulate meaningful business questions, interpret query results, and synthesize findings
into actionable business insights required a different way of thinking. Developing executive-level insights was particularly demanding
because it involved reviewing results across multiple analyses and identifying meaningful relationships between different business metrics rather than simply describing individual query outputs.

Overall, this project has been one of the most rewarding milestines in my upskilling journey. It challenged both my technical and 
analytical abilities while teaching me how to transform raw transactional data into business insights that support data-driven decision-making. Completing this project has strengthened my confidence as an aspiring data analyst, and I am grateful for the oppotunity to develop a skill that I have worked hard to build.

# Feedback
I'm continuously improving my SQL and analytics skills. If you have suggestions on improving the SQL logic, business
interpretation, or overall project structure, I'd genuinely appreciate your feedback. Constructive discussions are always welcome.
  

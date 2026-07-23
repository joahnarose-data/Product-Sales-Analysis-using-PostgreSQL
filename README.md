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
- Microsoft Excel (Initial Inspection)
- pgAdmin 4
- PostgreSQL
- SQL
- GitHub

# Dataset
- Source: Kaggle
- Link: https://www.kaggle.com/datasets/yusufdelikkaya/online-sales-dataset
- Records: 49,782 transactions
- Industry: Retail / E-commerce 
- Data includes:
  - Products
  - Categories
  - Sales Channels (In-Store & Online)
  - Countries
  - Payment Methods
  - Discounts
  - Shipment Providers
  - Warehouse Locations
  - Returns

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
  

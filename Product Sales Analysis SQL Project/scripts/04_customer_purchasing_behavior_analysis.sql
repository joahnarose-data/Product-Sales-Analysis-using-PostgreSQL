-- =====================================================================
--                  SQL PROJECT 1: PRODUCT SALES ANALYSIS
--                 SECTION 4: CUSTOMER PURCHASING BEHAVIOR
-- =====================================================================



-- 1. What percentage of purchases are online transactions versus in-store transactions?

SELECT
    saleschannel,
    COUNT(*) AS channel_count,
    SUM(COUNT(*)) OVER () AS total_positive_transactions,
    CONCAT(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2),'%') AS sales_channel_percentage
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY saleschannel;


/*
Query Logic:
    1. This analysis evaluates customers' preferred purchasing channel by comparing
    the proportion of online and in-store transactions.


Results:
    1. saleschannel	    channel_count	total_dataset_count	sales_channel_percentage
        In-Store	        23531	            49782	             47.27%
        Online	            23762	            49782	             47.73%

Business Insights:
    1. Online sales channel contributed a purchase percentage of slightly 
    higher than the In-Store sales channel. Customers' sales channel preferences 
    were close to equal distribution both having channel preference count of 23K. 
    This result suggest that there is a minimal dominance of channel preference 
    and that there is a fair distribution of customers per mode of transaction.

*/

-- 2. Which sales channel is preferred by transaction count according to product category (all years)?

WITH transaction_count AS (
        SELECT 
        category,
        saleschannel,
        COUNT(*) AS transactionstatus_count,
        SUM(COUNT(*)) OVER(PARTITION BY category) AS totaltransactionstatus_count
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY category, saleschannel
)

SELECT 
    category,
    saleschannel,
    transactionstatus_count,
    totaltransactionstatus_count,
    RANK() OVER(PARTITION BY category ORDER BY transactionstatus_count DESC) AS rankpercategory,
    CONCAT(ROUND(((transactionstatus_count*100.0) / totaltransactionstatus_count),2), '%') AS transactionstatus_percentage
FROM transaction_count



-- Breakdown on Sales Channnel Preference Transaction Count Per Year

WITH transaction_count AS (
        SELECT 
        category,
        saleschannel,
        EXTRACT(YEAR FROM invoicedate) AS year,
        COUNT(*) AS transaction_count,
        SUM(COUNT(*)) OVER(PARTITION BY EXTRACT (YEAR FROM invoicedate), category) AS totaltransaction_count
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY EXTRACT(YEAR FROM invoicedate), category, saleschannel
)

SELECT 
    year,
    category,
    saleschannel,
    transaction_count,
    totaltransaction_count,
    RANK() OVER(PARTITION BY year, category ORDER BY transaction_count DESC) AS rankpercategory,
    CONCAT(ROUND(((transaction_count*100.0) / totaltransaction_count),2), '%') AS transactioncount_percentage
FROM transaction_count
/*

Query Logic:
    1. This analysis will help us evaluate whether customers within each category display different
    channel preferences.


Results:
    1. 
    category	    saleschannel	transaction_count	    totaltransaction_count	        rankpercategory	    transaction_percentage
    Accessories	    In-Store	            4355	                8673	                        1	              50.21%
    Accessories	    Online	                4318	                8673	                        2	              49.79%
    Apparel	        In-Store	            2148	                4268	                        1	              50.33%
    Apparel	        Online	                2120	                4268	                        2	              49.67%
    Electronics	    Online	                6431	                12857	                        1	              50.02%
    Electronics	    In-Store	            6426	                12857	                        2	              49.98%
    Furniture	    Online	                6569	                13001	                        1	              50.53%
    Furniture	    In-Store	            6432	                13001	                        2	              49.47%
    Stationery	    Online	                4324	                 8494	                        1	              50.91%
    Stationery	    In-Store	            4170	                 8494	                        2	              49.09%

Business Insights:
    1. Sales Channel preferences per category is close to equal distribution of transaction
    count percentage. With a minimal percentage-point dominance, In-Store is more preferred by
    customers in Accessories and Apparel while Online is more preferred in Electronics, Furniture, 
    and Stationery. The result suggests that there is a closely fair distribution of customers in 
    online and in-store for all the product categories.

*/


-- 3. Which sales channel is preferred by average quantity sold per transaction according to product category?

WITH quantity_sold AS (
        SELECT 
        category,
        saleschannel,
        SUM(quantity) AS quantity_count,
        ROUND(AVG(quantity),2) AS avgquantity_count
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY category, saleschannel
)

SELECT 
    category,
    saleschannel,
    avgquantity_count,
    quantity_count,
    SUM(quantity_count) OVER(PARTITION BY category) AS totalquantity_countpercategory,
    RANK() OVER(PARTITION BY category ORDER BY quantity_count DESC) AS rankpercategory,
    CONCAT(ROUND(((quantity_count*100.0)/(SUM(quantity_count) OVER(PARTITION BY category))),2), '%') AS quantitycount_percentage
FROM quantity_sold

/*
Query Logic:
    1. This analysis will help us evaluate whether sales channel preference by customers could be associated with the 
    quantity of their purchase.  

Result:

category	       saleschannel	avgquantity_count	quantity_count	totalquantity_countpercategory	rankpercategory	quantitycount_percentage
Accessories	         In-Store	    24.90	            108458	            216715	                        1	            50.05%
Accessories	         Online	        25.07	            108257	            216715	                        2	            49.95%
Apparel	             In-Store	    24.72	             53102	            105784	                        1	            50.20%
Apparel	             Online	        24.85	             52682	            105784	                        2	            49.80%
Electronics	         Online	        24.95	            160472	            320795	                        1	            50.02%
Electronics	         In-Store	    24.95	            160323	            320795	                        2	            49.98%
Furniture	         Online	        24.73	            162442	            323573	                        1	            50.20%
Furniture	         In-Store	    25.05	            161131	            323573	                        2	            49.80%
Stationery	         Online	        24.86	            107493	            210425	                        1	            51.08%
Stationery	         In-Store	    24.68	            102932	            210425	                        2	            48.92%

Business Insights
    1. Quantity count percentage per sales channel were fairly distributed across each category with just
    small point differences. Results in average quantity per transaction showed little to no association of 
    purchase quantity and sales channel preference.

*/


-- 4. How do product categories rank on online purchases by transaction count and quantity sold?

WITH onlinetransactions_count AS (
    SELECT
        category,
        COUNT(*) AS onlinetransaction_count,
        SUM(COUNT(*)) OVER() AS totalonlinetransaction_count,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS total_revenue
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
      AND saleschannel = 'Online'
    GROUP BY category
),

quantity AS (
    SELECT
        category,
        SUM(quantity) AS totalquantity_countpercategory
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
      AND saleschannel = 'Online'
    GROUP BY category
)

SELECT
    ot.category,
    ot.total_revenue,
    ot.totalonlinetransaction_count,
    ot.onlinetransaction_count,
    RANK() OVER (ORDER BY ot.onlinetransaction_count DESC) AS rankpernumberoftransactions,
    CONCAT(ROUND(ot.onlinetransaction_count * 100.0 / ot.totalonlinetransaction_count, 2),'%') AS onlinetransaction_percentage,
    q.totalquantity_countpercategory,
    CONCAT(ROUND(q.totalquantity_countpercategory * 100.0 / SUM(q.totalquantity_countpercategory) OVER (),2),'%') AS quantitycount_percentage,
    RANK() OVER (ORDER BY q.totalquantity_countpercategory DESC) AS rankpernumberofquantitysold
FROM onlinetransactions_count ot
INNER JOIN quantity q
    ON ot.category = q.category
ORDER BY rankpernumberoftransactions;

/*
Query Logic:
    1. This analysis will help us evaluate the product category performance in online sales channel
    based on transaction counts and quantity sold counts.

Results:
    
    category	    total_revenue	totalonlinetransaction_count	onlinetransaction_count	rankpernumberoftransactions	onlinetransaction_percentage	totalquantity_countpercategory	quantitycount_percentage	rankpernumberofquantitysold
    Furniture	    6155018.41	            23762	                        6569	                    1	                    27.64%	                            162442	                    27.47%	                        1
    Electronics	    6059558.71	            23762	                        6431	                    2	                    27.06%	                            160472	                    27.14%	                        2
    Stationery	    4041902.85	            23762	                        4324	                    3	                    18.20%	                            107493	                    18.18%	                        4
    Accessories	    4149567.15	            23762	                        4318	                    4	                    18.17%	                            108257	                    18.31%	                        3
    Apparel	        1964817.05	            23762	                        2120	                    5	                    8.92%	                             52682	                     8.91%	                        5


Business Insights:
    1. Furniture ranked first for both transaction counts and quantity sold counts followed by Electronics. Results showed that higher 
    transaction counts appeared to be driven by the number of product lines per category as supported by previous query results. Moreover,
    categories with similar number of products only have small point differences on each of their transaction and quantity counts.


*/

-- 5. How do product categories rank on in-store purchases by transaction count and quantity sold?

WITH instoretransactions_count AS (
    SELECT
        category,
        COUNT(*) AS instoretransaction_count,
        SUM(COUNT(*)) OVER() AS totalinstoretransaction_count
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
      AND saleschannel = 'In-Store'
    GROUP BY category
),

quantity AS (
    SELECT
        category,
        SUM(quantity) AS totalquantity_countpercategory
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
      AND saleschannel = 'In-Store'
    GROUP BY category
)

SELECT
    ot.category,
    ot.totalinstoretransaction_count,
    ot.instoretransaction_count,
    RANK() OVER (ORDER BY ot.instoretransaction_count DESC) AS rankpernumberoftransactions,
    CONCAT(ROUND(ot.instoretransaction_count * 100.0 / ot.totalinstoretransaction_count, 2),'%') AS instoretransaction_percentage,
    q.totalquantity_countpercategory,
    CONCAT(ROUND(q.totalquantity_countpercategory * 100.0 / SUM(q.totalquantity_countpercategory) OVER (),2),'%') AS quantitycount_percentage,
    RANK() OVER (ORDER BY q.totalquantity_countpercategory DESC) AS rankpernumberofquantitysold
FROM instoretransactions_count ot
INNER JOIN quantity q
    ON ot.category = q.category
ORDER BY rankpernumberoftransactions;

/*

Query Logic:
    1. This analysis will help us determine the product category performance in in-store
    sales channel based on transaction counts and quantity sold counts.

Results:
    
    category	totalinstoretransaction_count	instoretransaction_count	rankpernumberoftransactions	instoretransaction_percentage	totalquantity_countpercategory	quantitycount_percentage	rankpernumberofquantitysold
    Furniture	        23531	                        6432	                        1	                        27.33%	                        161131	                    27.50%	                        1
    Electronics	        23531	                        6426	                        2	                        27.31%	                        160323	                    27.36%	                        2
    Accessories	        23531	                        4355	                        3	                        18.51%	                        108458	                    18.51%	                        3
    Stationery	        23531	                        4170	                        4	                        17.72%	                        102932	                    17.57%	                        4
    Apparel	            23531	                        2148	                        5	                        9.13%	                         53102	                     9.06%	                        5

Business Insights
    1. Similar to the previous result in online sales channel, Furniture still ranked first
    on both transaction counts and quantity counts followed by Electronics. Results suggest that 
    Furniture and Electronics were the top 2 categories leading on both sales channel. Moreover,
    it is noticeable that customer purchasing behavior is balanced across sales channels and that 
    furniture remained first whether customer purchase is online or in-store.

*/


-- 6. Which countries generated the highest number of online purchases and highest number of in-store purchases?

WITH top_online AS(
    SELECT 
    country,
    COUNT(country) AS country_count,
    'Online' AS saleschannel
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction' 
AND saleschannel = 'Online'
GROUP BY country
ORDER BY country_count DESC
),

top_instore AS(
SELECT 
    country,
    COUNT(country) AS country_count,
    'In-Store' AS saleschannel
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction' 
AND saleschannel = 'In-Store'
GROUP BY country
ORDER BY country_count DESC
)

SELECT saleschannel, country, country_count FROM top_online
UNION ALL
SELECT saleschannel, country, country_count FROM top_instore;

/*

Query Logic:
    1. This analysis will provide an overview on the leading countries each for online 
    and in-store sales channels based on the number of purchases.

Results:
    
saleschannel	country	        country_count
In-Store	    Germany	            2036
In-Store	    United Kingdom	    2018
In-Store	    France	            1994
In-Store	    Portugal	        1992
In-Store	    Belgium	            1982
In-Store	    Sweden	            1958
In-Store	    Spain	            1947
In-Store	    Netherlands	        1945
In-Store	    Norway	            1938
In-Store	    Italy	            1934
In-Store	    United States	    1911
In-Store	    Australia	        1876
Online	        Sweden	            2036
Online	        France	            2027
Online	        Australia	        2018
Online	        Netherlands	        2012
Online	        Norway	            2000
Online	        Belgium	            1981
Online	        United States	    1969
Online	        Portugal	        1967
Online	        United Kingdom	    1955
Online	        Spain	            1950
Online	        Germany	            1936
Online	        Italy	            1911
 
Buiness Insights:
    1. The countries generating the highest number of online purchases were Sweden, France, 
    Australia, Netherlands, and Norway, while Germany, United Kingdom, France, Portugal,
     and Belgium recorded the highest number of in-store purchases. France ranked among the 
     leading countries in both sales channels, indicating balanced transaction activity 
     across online and in-store purchases. Moreover, transaction counts across countries were 
     relatively close, suggesting no substantial dominance of either sales channel by country.

*/

-- 7. How do countries rank for overall number of transactions (online & in-store)?

SELECT 
    country,
    COUNT(country) AS country_count,
    RANK() OVER(ORDER BY COUNT(country) DESC) AS country_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY country;

/*
Query Logic:
    1. This analysis will help us evaluate on the transaction counts per country and to 
    assess whether there is a significantly dominating country.

Results:
    
    country	        country_count	country_rank
    France	            4021	        1
    Sweden	            3994	        2
    United Kingdom	    3973	        3
    Germany	            3972	        4
    Belgium	            3963	        5
    Portugal	        3959	        6
    Netherlands	        3957	        7
    Norway	            3938	        8
    Spain	            3897	        9
    Australia	        3894	        10
    United States	    3880	        11
    Italy	            3845	        12

Business Insights:
    1. France ranked first in overall transaction count, consistent with its 
    presence among the leading countries in both online and in-store purchases. 
    Across all countries, transaction counts ranged narrowly from 3,845 to 4,021, 
    indicating a fairly balanced distribution of purchasing activity with no single 
    country contributing a disproportionately large share of total transactions.

*/


-- ====================================================================
--                         SECTION KEY FINDINGS
-- ====================================================================

/*

1. Online and In-Store purchases are consistently distributed across transaction volume,
product categories, products, and customer countries. Although Online purchases frequently
rank first, the differences from In-Store purchases remain small, indicating no clear
dominance of either sales channel.

2. Categories with a greater number of product lines generally generate higher transaction
volumes and revenue. Electronics and Furniture, which contain more products than the other
categories, consistently ranked among the top-performing categories across multiple analyses.

*/
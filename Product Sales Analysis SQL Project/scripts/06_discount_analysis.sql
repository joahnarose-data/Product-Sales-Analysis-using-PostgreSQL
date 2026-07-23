
-- =====================================================================
--                  SQL PROJECT 1: PRODUCT SALES ANALYSIS
--                     SECTION 6: DISCOUNT ANALYSIS
-- =====================================================================


-- 1. What is the average discount per category?

SELECT
    category,
    ROUND(AVG(discount)*100,2) AS average,
    DENSE_RANK() OVER(ORDER BY ROUND(AVG(discount),2) DESC) AS average_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY category

/*

Query Logic:
    1. This analysis will help evaluate discounts and determine whether they are
    associated with the results of the succeeding analyses.


Result:
    
    category	   average	average_rank
    Stationery	    24.99	    1
    Accessories	    25.02	    1
    Electronics	    25.02	    1
    Furniture	    25.07	    1
    Apparel	        25.19	    1


Business Insights:
    1. Results show that average discounts across categories
    are uniformly distributed with no category offering significantly 
    higher average discounts. 

*/

-- 2. Does higher discount lead to higher sales quantity?

WITH discount_groups AS(
    SELECT 
        CASE
            WHEN discount = 0 THEN 'No Discount'
            WHEN discount <= 0.10 THEN 'Low Discount'
            WHEN discount <= 0.20 THEN 'Medium Discount'
            ELSE 'High Discount'
        END AS discount_level,
        COUNT(*) AS transactions,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(quantity),2) AS avg_quantity_per_transaction,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY 
        CASE
            WHEN discount = 0 THEN 'No Discount'
            WHEN discount <= 0.10 THEN 'Low Discount'
            WHEN discount <= 0.20 THEN 'Medium Discount'
            ELSE 'High Discount'
        END
)

SELECT 
    discount_level,
    transactions,
    CONCAT(
        ROUND((transactions * 100.0) / SUM(transactions) OVER(), 2),
        '%'
    ) AS transaction_percentage,
    avg_quantity_per_transaction,
    total_quantity,
    revenue,
    DENSE_RANK() OVER(ORDER BY total_quantity DESC) AS quantity_rank
FROM discount_groups
ORDER BY quantity_rank;

/*

Query Logic:
    1. This analysis will help in understanding the impact of discount offers on sales quantity.

Result:
    
discount_level	    transactions	transaction_percentage	avg_quantity_per_transaction	total_quantity	revenue	    quantity_rank
High Discount	      27968	                59.14%	                24.92	                    696926	    22644597.71	     1
Low Discount	       9380	                19.83%	                24.98	                    234316	    11222314.67	     2
Medium Discount	       9459	                20.00%	                24.69	                    233498	    10126976.48	     3
No Discount	            486	                1.03%	                25.83	                     12552	    639805.61	     4


Business Insights:
    1. Results show significantly higher transactions and total quantity sold
    for products with high discount offers compared to lower discount offers and products 
    with no discounts. This suggests an association between higher discount levels and 
    greater sales quantity. Morevoer, average quantity per transaction showed relatively close 
    values, indicating that the quantity per transaction is unlikely to be explained by the level 
    of discount offers. Rather, higher sales quantity at high discount level is potentially
    associated with the number of customer transactions.
*/


-- 3. Which products receive discounts most frequently, and which products are most often sold without discounts?

SELECT
    description,
    ROUND(AVG(discount),2) AS avg_discount,
    COUNT(CASE WHEN discount != 0 THEN 1 END) AS discountsinpurchase_count,
    DENSE_RANK() OVER(ORDER BY COUNT(CASE WHEN discount != 0 AND transaction_status != 'Negative Transaction' THEN 1 END) DESC) AS rank ,
    COUNT(CASE WHEN discount = 0 THEN 1 END) AS nodiscount_count,
    DENSE_RANK() OVER(ORDER BY COUNT(CASE WHEN discount = 0 AND transaction_status != 'Negative Transaction' THEN 1 END) ASC) AS ndcount_rank,
    ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
    COUNT(*) AS transactions
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY description

/*

Query Logic:
    1. This analysis will determine products' performance based on discounts and 
    other supporting metrics.

Result:
    
description	avg_discount	discountsinpurchase_count	rank	nodiscount_count	ndcount_rank	revenue	    transactions
USB Cable	    0.25	            4323	             1	            36	            2	        4104764.70	    4359
Wall Clock	    0.25	            4308	             2	            54	            7	        4073287.02	    4362
Backpack	    0.25	            4305	             3	            50	            6	        4082019.31	    4355
Desk Lamp	    0.25	            4279	             4	            59	            9	        4099578.68	    4338
White Mug	    0.25	            4277	             5	            41	            3	        4190846.23	    4318
Office Chair	0.25	            4255	             6	            46	            5	        3987498.30	    4301
Headphones	    0.25	            4239	             7	            43	            4	        4040060.59	    4282
T-shirt 	    0.25	            4232	             8	            36	            2	        3996341.79	    4268
Blue Pen	    0.25	            4209	             9	            55	            8	        4028690.06	    4264
Notebook	    0.25	            4197	             10	            33	            1	        3986598.41	    4230
Wireless Mouse	0.25	            4183	             11	            33	            1	        4044009.38	    4216


Business Insights:
    1. USB Cable ranked first for products often sold with discounts, while Wireless Mouse and Notebook
    are products most often sold without discounts. While average discounts are noticeably uniform across
    all products, it's also worth noticing that revenue generated by all products is closely clustered.
    Since discount frequency and average discount are nearly identical across products, differences in 
    product performance are unlikely to be explained by discount practices alone.

*/


-- 4. Which categories rely most heavily on discounts?

SELECT
    category,
    COUNT(*) AS total_transactions,
    COUNT(CASE WHEN discount > 0 THEN 1 END) AS discounted_transactions,
    ROUND(COUNT(CASE WHEN discount > 0 THEN 1 END)*100.0 / COUNT(*),2) AS discount_usage_rate,
    DENSE_RANK() OVER(ORDER BY ROUND(COUNT(CASE WHEN discount > 0 THEN 1 END)*100.0 
    /
     COUNT(*),2) DESC) AS discount_usage_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY category
ORDER BY discount_usage_rate DESC;

/*

Query Logic:
    1. This analysis will help us evaluate discount usage of categories and assess results
    with combined analysis on previous query results.

Result:
    
    category	    total_transactions	discounted_transactions	discount_usage_rate	discount_usage_rank
    Apparel	                4268	            4232	            99.16	                1
    Electronics	            12857	            12745	            99.13	                2
    Stationery	            8494	            8406	            98.96	                3
    Accessories	            8673	            8582	            98.95	                4
    Furniture	            13001	            12842	            98.78	                5

Business Insights:

    1. Results show that discount usage rates are fairly consistent across all categories, ranging
    only from 98.78% to 99.16%. As supported by previous query results, this suggests that differences
    in category revenue are unlikely to be explained by discount usage alone, since nearly all
    categories apply discounts at almost the same frequency.

*/

-- 5. What is the relationship between discount and revenue?

WITH discount_groups AS(
    SELECT 
        CASE
            WHEN discount = 0 THEN 'No Discount'
            WHEN discount <= 0.10 THEN 'Low Discount'
            WHEN discount <= 0.20 THEN 'Medium Discount'
            ELSE 'High Discount'
            END AS discount_level,
            COUNT(*) AS transaction_count,
            ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS revenue,
            ROUND(((SUM((quantity*unitprice)*(1-discount)))/(COUNT(*))),2) AS avg_revenue_pertransaction
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY 
        CASE
            WHEN discount = 0 THEN 'No Discount'
            WHEN discount <= 0.10 THEN 'Low Discount'
            WHEN discount <= 0.20 THEN 'Medium Discount'
            ELSE 'High Discount'
        END
)

SELECT 
    discount_level,
    transaction_count,
    revenue,
    DENSE_RANK() OVER(ORDER BY revenue DESC) AS revenue_rank,
    avg_revenue_pertransaction,
    DENSE_RANK() OVER(ORDER BY avg_revenue_pertransaction DESC) AS avg_revenue_rank
FROM discount_groups

/*

Query Logic:
    1. This analysis will evaluate the potential association of discount offers and generated 
    revenue.

Result:
    
    discount_level	transaction_count	revenue	        revenue_rank	avg_revenue_pertransaction	avg_revenue_rank
    High Discount	    27968	        22644597.71	         1	                    809.66	                4
    Low Discount	    9380	        11222314.67	         2	                    1196.41	                2
    Medium Discount	    9459	        10126976.48	         3	                    1070.62	                3
    No Discount	        486	            639805.61	         4	                    1316.47	                1


Business Insights:

    1. High discount offerings appear to be associated with the highest revenue, highest transaction
    count, and the lowest average revenue per transaction. Results further support previous query
    findings that high discount offerings are associated with a higher volume of transactions, which
    likely contributes to higher total revenue.

*/


-- 6. What is the relationship between discount and returns?

WITH discount_groups AS(
    SELECT 
        CASE
            WHEN discount = 0 THEN 'No Discount'
            WHEN discount <= 0.10 THEN 'Low Discount'
            WHEN discount <= 0.20 THEN 'Medium Discount'
            ELSE 'High Discount'
            END AS discount_level,
            COUNT(*) AS transactions,
            COUNT(CASE WHEN returnstatus =  'Returned' THEN 1 END) AS returns_count
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY 1
)

SELECT 
    discount_level,
    transactions,
    returns_count,
    CONCAT(ROUND((returns_count*100.0/NULLIF(transactions,0)),2),'%') AS return_rate,
    DENSE_RANK() OVER(ORDER BY ROUND((returns_count*100.0/NULLIF(transactions,0)),2) DESC) AS return_rate_rank
FROM discount_groups

/*

Query Logic:
    1. This analysis will further evaluate discount offerings and their 
    association to return rates 

Result:
    
    discount_level	transactions	returns_count	return_rate	return_rate_rank
    No Discount	        486	            49	         10.08%	            1
    High Discount	    27968	        2755	     9.85%	            2
    Medium Discount	    9459	        932	         9.85%	            2
    Low Discount	    9380	        910	         9.70%	            3


Business Insights:
    1. Return rates across discount levels are relatively close, ranging from
    9.70% to 10.08% with just a difference of 0.38% percentage points.'No Discount' 
    had the highest return rate followed by High and Medium discounts. Results 
    indicate that return rates are fairly distributed across discount levels 
    and appear to show minimal association with discount offerings.
*/



-- ====================================================================
--                         SECTION KEY FINDINGS
-- ====================================================================

/*

    1. High discount offerings are associated with substantially higher transaction
counts, greater total quantity sold, and higher overall revenue. Results suggest
that increased sales volume is more likely driven by the greater number of customer
transactions rather than higher quantities purchased per transaction.

2. Discount practices are consistently applied across products and categories.
Discount usage rates, average discount values, and discount frequencies remain
relatively uniform, suggesting that differences in product and category performance
are unlikely to be explained by discount strategies alone.

3. Return rates remain relatively consistent across all discount levels, with only
small percentage-point differences. These findings suggest that discount offerings
show minimal association with product return behavior despite their association with
higher sales volume.

*/
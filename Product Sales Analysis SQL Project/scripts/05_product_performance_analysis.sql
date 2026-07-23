
-- =====================================================================
--                  SQL PROJECT 1: PRODUCT SALES ANALYSIS
--                     SECTION 5: PRODUCT PERFORMANCE
-- =====================================================================


-- 1. Which products have the highest sales volume?

SELECT
    description,
    SUM(quantity) AS overallsales_volume,
    RANK() OVER(ORDER BY SUM(quantity) DESC) AS salesvolume_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY description;

/*

Query Logic:
    1. This analysis will help us evaluate product performance based on the volume of sales.

Result:
    
    description	    overallsales_volume	salesvolume_rank
    USB Cable	        109279	                1
    Wall Clock	        108922	                2
    White Mug	        108415	                3
    Backpack	        108300	                4
    Desk Lamp	        107857	                5
    Office Chair	    106794	                6
    Wireless Mouse	    106159	                7
    Blue Pen	        105870	                8
    T-shirt	            105784	                9
    Headphones	        105357	                10
    Notebook	        104555	                11

Business Insights:
    1. USB Cable recorded the highest sales volume with 109,279 units sold, followed
    closely by Wall Clock with 108,922 units. Sales volumes across all products were
    relatively similar, ranging from approximately 104.6 thousand to 109.3 thousand
    units. This indicates that customer demand was well distributed across all the 
    products, with no single product demonstrating a dominant share of total sales volume.

*/


-- 2. Which products generate the highest revenue?

WITH productrev AS(
SELECT
    description,
    ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
    RANK() OVER(ORDER BY ROUND(SUM((quantity * unitprice) * (1 - discount)),2) DESC) AS revenue_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY description
),

totalrev AS (
    SELECT 
    ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS totalrevenue
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
)

SELECT 
    pr.description,
    pr.revenue,
    CONCAT(ROUND((pr.revenue*100.0/tr.totalrevenue),2),'%') AS revenue_percentage,
    pr.revenue_rank
FROM productrev pr
CROSS JOIN totalrev tr


/*

Query Logic:
    1. This analysis will provide an insights on product performance
    based on revenue.

Results:
    
    description	    revenue	    revenue_percentage	revenue_rank
    White Mug	    4190846.23	    9.39%	            1
    USB Cable	    4104764.70	    9.20%	            2
    Desk Lamp	    4099578.68	    9.18%	            3
    Backpack	    4082019.31	    9.15%	            4
    Wall Clock	    4073287.02	    9.13%	            5
    Wireless Mouse	4044009.38	    9.06%	            6
    Headphones	    4040060.59	    9.05%	            7
    Blue Pen	    4028690.06	    9.03%	            8
    T-shirt	        3996341.79	    8.95%	            9
    Office Chair	3987498.30	    8.93%	            10
    Notebook	    3986598.41	    8.93%	            11

Business Insights:

    1. White Mug generated the highest revenue 4.2 million (9.39%) which was followed 
    closely by USB Cable and Desk Lamp. Product revenues were closely distributed 
    ranging from 4.0 million to 4.2 million, each contributing to revenue shares of 
    approximately 9.0%. Results show that product revenues are distributed across all 
    products and that there is no single product line dominating the business.

*/


-- 2A. Which products have the highest average revenue per transaction?

SELECT
    description,
    ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS Revenue,
    COUNT(*) AS transaction_count,
    ROUND(SUM((quantity * unitprice) * (1 - discount))/(COUNT(*)),2) AS averagepertransaction_value,
    RANK() OVER(ORDER BY ROUND(SUM((quantity * unitprice) * (1 - discount))/(COUNT(*)),2) DESC) AS averagepertransaction_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY description;


/*

Results:
    
    description	    revenue	    transaction_count	averagepertransaction_value	averagepertransaction_rank
    White Mug	    4190846.23	    4318	                970.55	                        1
    Wireless Mouse	4044009.38	    4216	                959.21	                        2
    Desk Lamp	    4099578.68	    4338	                945.04	                        3
    Blue Pen	    4028690.06	    4264	                944.81	                        4
    Headphones	    4040060.59	    4282	                943.50	                        5
    Notebook	    3986598.41	    4230	                942.46	                        6
    USB Cable	    4104764.70	    4359	                941.68	                        7
    Backpack	    4082019.31	    4355	                937.32	                        8
    T-shirt	        3996341.79	    4268	                936.35	                        9
    Wall Clock	    4073287.02	    4362	                933.81	                        10
    Office Chair	3987498.30	    4301	                927.11	                        11

Business Insights:
    1. White Mug has the highest average revenue per transaction. As supported by the results on
    previous sections higher pricing and a relatively low return rate are the potential drivers of 
    White Mug's higher revenue among all products. Average revenue per transaction on all products
    noticeably showed relatively consistent values indicating a fair distribution of customers' 
    product preferences.

*/



-- 3. Which products are top-ranked within each category?

WITH top_product AS(
SELECT
    description,
    category,
    ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS Revenue,
    DENSE_RANK() OVER(PARTITION BY category ORDER BY ROUND(SUM((quantity * unitprice) * (1 - discount)),2) DESC) AS product_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
AND returnstatus = 'Not Returned'
GROUP BY description, category
)

SELECT
    category,
    description
FROM top_product
WHERE product_rank = 1;

/*

Query Logic:
    1.This analysis will distinguish all the top performing products
    per category. 

Results:
    
    category	    description
    Accessories	    White Mug
    Apparel	        T-shirt
    Electronics	    USB Cable
    Furniture	    Desk Lamp
    Stationery	    Blue Pen

Business Insights
    1. Top ranked products are White Mug(Accessories), T-Sirt(Apparel), USB Cable(Electronics),
    Desk Lamp(Furniture), and Blue Pen(Stationery).

*/

-- What product is the top-performing per country?

WITH top_productpercountry AS(
SELECT
    country,
    description,
    COUNT(*) AS transaction_count,
    DENSE_RANK() OVER(PARTITION BY country ORDER BY COUNT(*) DESC) AS product_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY country, description
)
SELECT 
    country,
    description
FROM top_productpercountry
WHERE product_rank = 1;

/*
Query Logic:
    1.This analysis will help us evaluate top performing products per country.

Results:
    
country	        description
Australia	    Desk Lamp
Belgium	        Office Chair
France	        Desk Lamp
Germany	        USB Cable
Italy	        Office Chair
Netherlands	    Wall Clock
Norway	        Backpack
Portugal	    Wall Clock
Spain	        Backpack
Sweden	        T-shirt
United Kingdom	Office Chair
United States	Notebook

Business Insights:
    1. From the 12 countries, Desk Lamp tops in Australia and France, Office Chair 
    leads in Belgium, Italy, and United Kingdom, Wall Clock tops in Netherlands and Portugal,
    Backpack in Norway and Spain, USB cable in Germany, T-Shirt in Sweden, and Notebook in 
    United States. Results suggest that there is no single product dominating all countries.

*/

-- 4. Which products perform consistently across multiple countries?

WITH top_productspercountry AS(
SELECT
    country,
    description,
    COUNT(*) AS transaction_count,
    DENSE_RANK() OVER(PARTITION BY country ORDER BY COUNT(*) DESC) AS product_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY country, description
),
top_products AS(
SELECT 
    description
FROM top_productspercountry
WHERE product_rank = 1
)
SELECT 
    description,
    COUNT(*) AS top_country_count,
    DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rank
FROM top_products
GROUP BY description;

/*

Query Logic:
    1.This analysis identifies products that consistently rank as 
    the top-performing product across multiple countries, highlighting 
    products with broad international demand.

Results:
    
    description	    top_country_count	        rank
    Office Chair	    3	                     1
    Desk Lamp	        2	                     2
    Backpack	        2	                     2
    Wall Clock	        2	                     2
    Notebook	        1	                     3
    T-shirt	            1	                     3
    USB Cable	        1	                     3

Business Insights:

    1. Office Chair emerged as the most consistently top-performing product,
    ranking first in three countries. Desk Lamp, Backpack, and Wall Clock each
    ranked first in two countries, while the remaining products led in only one
    country. These results indicate that customer preferences differ across markets,
    with no single product overwhelmingly dominating international demand. This finding 
    is consistent with previous analyses showing relatively balanced product demand 
    across countries. 

*/


-- 5. Which categories contain the highest number of products sold?

SELECT
    category,
    SUM(quantity) AS products_sold,
    RANK() OVER(ORDER BY SUM(quantity) DESC) AS category_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
AND returnstatus = 'Not Returned'
GROUP BY category;

/*
Query Logic:
    1. This analysis evaluates category performance by identifying 
    which product categories recorded the highest number of products 
    sold. It also serves to validate trends observed in previous analyses 
    regarding category demand.

Result:
    
    category        products_sold	category_rank
    Furniture	        292918	        1
    Electronics	        288674	        2
    Accessories	        195871	        3
    Stationery	        188066	        4
    Apparel	             95685	        5

Business Insights:

    1. Furniture recorded the highest number of products sold, followed closely
    by Electronics. While Furniture and Electronics exhibited similar sales volume,
    both categories substantially outperformed Accessories, Stationery, and Apparel.
    This suggests that customer demand is strongest for Furniture and Electronics, 
    with no clear leader between the two categories. Moreover, as observed in the 
    previous analysis, these categories also contain a larger number of product
    line than the remaining categories. Therefore, their higher sales volumes may
    be partially influenced by their broader product offerings. 

*/


--5A. Which categories generate the highest successful sales transactions?

SELECT
    category,
    COUNT(*) AS transaction_count,
    RANK() OVER(ORDER BY COUNT(*) DESC) AS category_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
AND returnstatus = 'Not Returned'
GROUP BY category;


/*
Query Logic:
    1. This analysis will closely evaluate whether category ranking still remain
    by focusing on only successful sales transactions which will exclude transactions
    with returns status.

Result:

category	transaction_count	category_rank
Furniture	    11745	            1
Electronics	    11603	            2
Accessories	    7840	            3
Stationery	    7620	            4
Apparel	        3839	            5

Business Insights:
    1. Results show that Furniture still leads the category ranking for 
    successful sales transactions, followed closely by Electronics. The 
    remaining categories have noticeably larger gaps compared with Furniture 
    and Electronics, indicating a possible association with the number of 
    product lines offered within each category. This observation is consistent 
    with the findings from previous analyses.

*/


--5B. How do category rankings change when returns are included?

SELECT
    category,
    COUNT(*) AS overalltransaction_count,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Not Returned' THEN 1 END) AS successfultransactions_count,
    COUNT(CASE WHEN returnstatus = 'Returned' THEN 1 END) AS returns_count,
    COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negativetransactions_count,
    RANK() OVER(ORDER BY COUNT(*) DESC) AS category_rank
FROM product_sales_clean
GROUP BY category;

/*
Query Logic:
    1. This analysis will help us evaluate whether rankings per category
    differ when looking closely into categories' return status.

Results:
    
    category	overalltransaction_count	successfultransactions_count	returns_count	negativetransactions_count	category_rank
    Furniture	        13684	                       11745	                1333	            683	                     1
    Electronics	        13583	                       11603	                1322	            726	                     2
    Accessories	         9086	                        7840	                 869	            413	                     3
    Stationery	         8963	                        7620	                 921	            469	                     4
    Apparel	             4466	                        3839	                 449	            198	                     5

Business Insights:
    1. Furniture ranked first for both overall transaction count and successful 
    transactions. Consistently, Furniture also recorded the highest number of 
    returns among all categories. However, Electronics recorded the highest number 
    of negative transactions. Moreover, the transaction counts across categories 
    appear to have a possible association with the number of products offered within 
    each category, which is consistent with previous findings.

*/


-- ====================================================================
--                         SECTION KEY FINDINGS
-- ====================================================================

/*

1. Transaction volumes across individual products remain relatively consistent.
Despite similar transaction counts, products differ in revenue generation, suggesting
that pricing and average order value contribute more to revenue differences than sales
volume alone.

2. Leading products vary across countries, with no single product consistently
dominating global demand. At most, the same product ranked first in only three out of
the twelve countries analyzed, indicating diverse purchasing preferences across markets.

3. Furniture and Electronics consistently ranked among the top-performing categories
in terms of transaction volume, units sold, and revenue. This supports earlier findings
that categories with a larger number of product lines generally exhibit stronger overall
performance.

*/

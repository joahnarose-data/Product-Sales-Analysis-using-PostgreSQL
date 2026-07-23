-- =====================================================================
--                  SQL PROJECT 1: PRODUCT SALES ANALYSIS
--                  SECTION 3: SALES PERFORMANCE ANALYSIS
-- =====================================================================


-- =====================================================================
--                              REVENUE
-- =====================================================================


-- 1. What is the total revenue generated?

WITH revenue AS(
SELECT 
    ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS totalsales_revenue,
    ROUND(SUM(CASE WHEN returnstatus = 'Returned' THEN ((quantity * unitprice) * (1 - discount)) END), 2) AS revenue_from_returns
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
)
SELECT 
    totalsales_revenue,
    revenue_from_returns,
    CONCAT(ROUND((revenue_from_returns * 100.0 / totalsales_revenue), 2),'%') AS return_rate
FROM revenue;


/*

Query Logic:
    1. Positive transactions were used as the analytical baseline because negative transactions 
    may represent cancellations, reversals, adjustments, or other operational events that do not 
    directly reflect completed sales performance.

Results:
    1.Total Revenue - 44.63 million
      Revenue from returns - 4.36 million
      Return rate - 9.76%

Business Insight: 
    1.Positive transactions generated a total revenue of 44.63 million from 2020 to 2025. Although 
    overall sales performance remained strong, approximately 9.76% of the revenue (4.36 million) was 
    associated with returned purchases, indicating that nearly one-tenth of completed sales were 
    later returned. This suggests that while revenue generation was substantial, returns remain an 
    important operational factor to monitor because they directly reduce realized sales value. 
*/



-- ====================================================================
--                          REVENUE x TIME
-- ====================================================================


-- 2. What is the annual revenue performance?

WITH annual_revenue AS(
SELECT 
    EXTRACT(YEAR FROM invoicedate) AS year,
    ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS total_revenue,
    ROUND(SUM(CASE WHEN returnstatus = 'Returned' THEN ((quantity * unitprice) * (1 - discount)) END),2) AS revenue_from_returns
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY EXTRACT(YEAR FROM invoicedate)
ORDER BY EXTRACT(YEAR FROM invoicedate)
)
SELECT 
    year,
    total_revenue,
    revenue_from_returns,
    CONCAT(ROUND((revenue_from_returns*100.0/total_revenue),2),'%') AS return_rate
FROM annual_revenue;



SELECT 
    EXTRACT(YEAR FROM invoicedate) AS year,
    COUNT(DISTINCT(EXTRACT(MONTH FROM invoicedate)))
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY year
ORDER BY year;

/*

Query Logic:
    1.Analysis of data on yearly basis provides a bird's eye view on the business's performance and 
    stability over time.

Results:
    
    year	total_revenue	revenue_from_returns	return_rate
    2020	  7854210.96	      750194.79	           9.55%
    2021	  7872588.49	      793885.10	           10.08%
    2022	  7818302.24	      763674.19	           9.77%
    2023      7793467.17          758610.46	           9.73%
    2024	  7952937.87          790120.09	           9.93%
    2025	  5342187.74	      499111.17	           9.34%

    year	count
    2020	 12
    2021	 12
    2022	 12
    2023	 12
    2024	 12
    2025	 9

Business Insights:

    1. Years 2020 to 2024 showed a stable revenue performance ranging between 7.7 million 
    to 7.9 million with a relatively consistent return rate of 9.3% to 10%. Unlike the previous 
    years, 2025 had a noticeable revenue decrease. Further investigation showed incomplete 
    month coverage. The data in 2025 only presented nine months, January to September, 
    instead of twelve months which affected the year's measured revenue.

*/

-- 3. What is the monthly revenue performance (seasonal performance)?

WITH monthrev AS (
    SELECT
        EXTRACT(MONTH FROM invoicedate) AS month_name,
        TO_CHAR(invoicedate, 'Month') AS month,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS total_revenue,
        ROUND(SUM((quantity * unitprice) * (1 - discount)) / 5,2) AS avg_monthlyrevenue,
        CONCAT(ROUND(COUNT(CASE WHEN returnstatus = 'Returned' THEN 1 END)*100.0 /
        (COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)),2), '%') AS return_rate
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    AND EXTRACT(YEAR FROM invoicedate) != 2025
    GROUP BY TO_CHAR(invoicedate, 'Month'),
    EXTRACT(MONTH FROM invoicedate)
),

totalrev AS (
    SELECT
        SUM((quantity * unitprice) * (1 - discount)) AS total_revenue
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    AND EXTRACT(YEAR FROM invoicedate) != 2025
)

SELECT
    mr.month,
    mr.total_revenue,
    mr.avg_monthlyrevenue,
    ROUND(mr.avg_monthlyrevenue / 
    CASE 
        WHEN TRIM(mr.month) IN ('January','March','May','July','August', 'October','December') THEN 31
        WHEN TRIM(mr.month) IN ('April','June','September','November') THEN 30
        WHEN TRIM(mr.month) IN ('February') THEN 28.4
    END ,2) AS avg_dailyrevenue,
    CONCAT(ROUND(mr.total_revenue * 100.0 / tr.total_revenue,2), '%') AS revenue_share,
    mr.return_rate
FROM monthrev mr
CROSS JOIN totalrev tr
ORDER BY month_name;

/*
Query Logic:
    1. Monthly analysis looks into the business's performance at a more specific and detailed view 
    which could help in identifying whether seasonality exists. 


Results:
    1. month	total_revenue	avg_monthlyrevenue	avg_dailyrevenue	revenue_share	return_rate
      January  	3327107.55	        665421.51	        21465.21	        8.47%	    9.95%
      February 	3043203.46	        608640.69	        21431.01	        7.75%	    10.27%
      March    	3326915.31	        665383.06	        21463.97	        8.47%	    9.62%
      April    	3251842.91	        650368.58	        21678.95	        8.28%	    10.26%
      May      	3274170.63	        654834.13	        21123.68	        8.33%	    9.79%
      June     	3222889.38	        644577.88	        21485.93	        8.20%	    9.73%
      July     	3289223.03	        657844.61	        21220.79	        8.37%	    9.96%
      August   	3333088.29	        666617.66	        21503.80	        8.48%	    10.09%
      September	3257548.02	        651509.60	        21716.99	        8.29%	    9.37%
      October  	3378210.93	        675642.19	        21794.91	        8.60%	    8.68%
      November 	3269195.60	        653839.12	        21794.64	        8.32%	    10.17%
      December 	3318111.62	        663622.32	        21407.17	        8.44%	    10.16%

Business Insight:

    1. For the monthly revenue performance, revenues were fairly stable ranging between 3.04 
    million to 3.38 million which is 7.75% to 8.60% of revenue shares. Average monthly revenues 
    were relatively consistent varying between 6.09 million to 6.76 million while the average 
    daily revenue was around 21.2K to 21.8K. Monthly return rates were also fairly consistent 
    spanning between 8.68% to 10.27%. No unusual patterns were present in transactions however 
    there was a minimal dip in February’s total revenue which was potentially affected by the 
    number of its transaction days being less than the other months. Other than this, the 
    generated monthly figures sit along the normal range revenue distribution. 

    Additionally, the results showed stability in total revenue, average monthly revenue,
    average daily revenue, revenue shares, and return rate. Separate Z-score tests also revealed
    no data outliers. Monthly business transactions showed no evidence of meaningful seasonality.

*/

-- 4. What is the year-month revenue trend?

WITH yearmonth AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', invoicedate), 'Mon-YYYY') AS month_period,
        EXTRACT(MONTH FROM invoicedate) AS month_no,
        EXTRACT(YEAR FROM invoicedate) AS year_no,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS total_revenue
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY
        DATE_TRUNC('month', invoicedate),
        EXTRACT(MONTH FROM invoicedate),
        EXTRACT(YEAR FROM invoicedate)
)

SELECT
    month_period,
    total_revenue
FROM yearmonth
ORDER BY
    month_no,
    year_no;



WITH september AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', invoicedate), 'Mon-YYYY') AS month_period,
        EXTRACT(MONTH FROM invoicedate) AS month_no,
        EXTRACT(YEAR FROM invoicedate) AS year_no,
        ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS total_revenue,
        COUNT(CASE WHEN returnstatus = 'Returned' THEN 1 END) AS returns,
        COUNT(DISTINCT EXTRACT(DAY FROM invoicedate)) AS days 
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    AND EXTRACT(MONTH FROM invoicedate) = 9
    GROUP BY
        DATE_TRUNC('month', invoicedate),
        EXTRACT(MONTH FROM invoicedate),
        EXTRACT(YEAR FROM invoicedate)
)

SELECT
    month_period,
    total_revenue,
    returns,
    days
FROM september
ORDER BY
    year_no,
    month_no;

/*

Query Logic

    1. To further analyze revenue performance over time, a year-month analysis was performed.

Results:

    1. month_period	total_revenue
        Sep-2025	87486.56
        
        (Note: Only the row with point anomaly was extracted from the whole results table.)

    2. month_period	total_revenue	returns	days
        Sep-2020	  664050.15	      82	30
        Sep-2021	  684578.56       61	30
        Sep-2022	  588442.82	      63	30
        Sep-2023	  639798.65	      57	30
        Sep-2024	  680677.84	      59	30
        Sep-2025	  87486.56	      11	5

Business Insights:

    1.From 2020-2025, monthly revenues were clustered into 595K to 696K. However, there is a noticeable 
    point anomaly in September 2025 which only generated 87K. Further analysis revealed that September 
    2025 only covered data for only five days instead of 30 days which significantly affected its revenue 
    computation.


*/


-- ====================================================================
--                         REVENUE X CATEGORY
-- ====================================================================


-- 5. Which categories contribute the largest percentage of total revenue?

WITH revenue_percategory AS (
    SELECT category,
           SUM(quantity) AS total_salesvolume,
           COUNT(DISTINCT description) AS product_count,
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS total_revenue_percategory,
           ROUND(SUM(CASE WHEN returnstatus = 'Returned' THEN ((quantity * unitprice) * (1 - discount)) END),2) AS revenue_from_returns,
           COUNT(CASE WHEN discount != 0 THEN 1 END) AS discount_count,
           ROUND(AVG(unitprice),2) AS avg_unitprice,
           ROUND(AVG(discount),2) AS avg_discount,
           COUNT(*) AS transactions,
           ROUND(AVG(quantity)) AS avg_salesvolume
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY category

),

total_revenue AS (
    SELECT 
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS totalrevenue
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'

)

SELECT 
    category,
    transactions,
    total_revenue_percategory,
    CONCAT(ROUND((total_revenue_percategory / total_revenue.totalrevenue)*100, 2),'%') AS revenue_share,
    product_count,
    total_salesvolume,
    avg_salesvolume,
    avg_unitprice,
    avg_discount,
    discount_count,
    revenue_from_returns,
    CONCAT(ROUND((revenue_from_returns*100.0/total_revenue_percategory),2),'%') AS return_rate,
    RANK() OVER(ORDER BY total_revenue_percategory DESC) AS rank_by_totalrevenue
FROM revenue_percategory
CROSS JOIN total_revenue
ORDER BY ROUND((total_revenue_percategory / total_revenue.totalrevenue)*100, 2) DESC;



SELECT 
    category,
    STRING_AGG(DISTINCT description, ', ') AS description
FROM product_sales_clean
GROUP BY category


/*

Query Logic:
    1. To provide an extensive overview on the category level sales-performance, it is essential to have an initial knowledge
    on a categorical basis.

Results:

    category	transactions	total_revenue_percategory	revenue_share	product_count	total_salesvolume	avg_salesvolume	avg_unitprice	avg_discount	revenue_from_returns	return_rate	rank_by_totalrevenue
    Electronics	12857	        12188834.67	                27.31%	            3	        320795	                25	        50.65	        0.25	        12745	                9.81%	            1
    Furniture	13001	        12160364.00	                27.24%	            3	        323573	                25	        50.24	        0.25	        12842	                9.42%	            2
    Accessories	8673	        8272865.54	                18.54%	            2	        216715	                25	        50.98	        0.25	        8582	                9.73%	            3
    Stationery	8494	        8015288.47	                17.96%	            2	        210425	                25	        50.64	        0.25	        8406	                10.18%	            4
    Apparel	    4268	        3996341.79	                8.95%	            1	        105784	                25	        50.54	        0.25	        4232	                9.86%	            5

    category	        description
    Accessories	    Backpack, White Mug
    Apparel	        T-shirt
    Electronics	    Headphones, USB Cable, Wireless Mouse
    Furniture	    Desk Lamp, Office Chair, Wall Clock
    Stationery	    Blue Pen, Notebook


Business Insights
    1. Electronics generated the highest revenue share of 27.31% (12.19 million) while Furniture 
    followed closely with 27.24%. These two categories also recorded the largest sales volume with 
    more than 320 thousand units sold, suggesting that their strong revenue performance was influenced
    by higher sales volume. Other two categories, Accessories and Stationery contribute a relatively 
    close revenue share with 18.54% and 17.96%. Apparel, with just one product under its category, 
    has the least revenue share with 8.95%. 
    
    Despite noticeable differences in revenue and sales volume, return rates remained relatively consistent 
    across all categories, with a normal variation ranging from 9.42% to 10.18%, with Stationery recording 
    the highest return rate. Likewise, higher returned revenue among Electronics and Furniture appears to 
    be a consequence of their larger sales volume rather than an unusually high likelihood of product returns.

*/

-- ====================================================================
--                      REVENUE X PRODUCTS
-- ====================================================================

-- 6. How do product descriptions rank according to revenue generated?

WITH revenue_perproduct AS(
    SELECT description,
           category,
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS total_revenue_perproduct,
           ROUND(SUM(CASE WHEN returnstatus = 'Returned' THEN ((quantity * unitprice) * (1 - discount)) END),2) AS revenue_from_returns,
           COUNT(CASE WHEN discount != 0 THEN 1 END) AS discount_count,
           ROUND(AVG(unitprice),2) AS avg_unitprice,
           ROUND(AVG(discount),2) AS avg_discount,
           COUNT(*) AS transactions,
           SUM(quantity) AS total_salesvolume
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY description, category
),

total_revenue AS (
    SELECT 
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS totalrevenue
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'

)

SELECT 
    description,
    category,
    transactions,
    total_revenue_perproduct,
    CONCAT(ROUND((total_revenue_perproduct / total_revenue.totalrevenue)*100, 2), '%') AS revenue_share,
    avg_salesvolume,
    avg_unitprice,
    avg_discount,
    revenue_from_returns,
    CONCAT(ROUND((revenue_from_returns*100.0/total_revenue_perproduct),2),'%') AS return_rate,
    RANK() OVER(ORDER BY total_revenue_perproduct DESC) AS rank_per_total_revenue
FROM revenue_perproduct
CROSS JOIN total_revenue
ORDER BY total_revenue_perproduct DESC;

/*

Query Logic
    1. Looking closely into product descriptions will provide us with a detailed view of product revenue performance
    and the associated metrics essential for product analysis.

Results:

    description	    category        transactions	total_revenue_perproduct	revenue_share	total_salesvolume	avg_salesvolume	avg_unitprice	avg_discount	revenue_from_returns	return_rate	rank_per_total_revenue
    White Mug	    Accessories        4318	            4190846.23	                9.39%	            108415	            25	           51.54	        0.25	        396844.79	        9.47%	            1
    USB Cable	    Electronics        4359	            4104764.70	                9.20%	            109279	            25	           50.14	        0.25	        420052.60	        10.23%	            2
    Desk Lamp	    Furniture          4338	            4099578.68	                9.18%	            107857	            25	           50.71	        0.25	        382611.32	        9.33%	            3
    Backpack	    Accessories        4355	            4082019.31	                9.15%	            108300	            25	           50.43	        0.25	        408238.77	        10.00%	            4
    Wall Clock	    Furniture          4362	            4073287.02	                9.13%	            108922	            25	           50.17	        0.25	        400265.99	        9.83%	            5
    Wireless Mouse	Electronics        4216	            4044009.38	                9.06%	            106159	            25	           51.01	        0.25	        411745.56	        10.18%	            6
    Headphones	    Electronics        4282	            4040060.59	                9.05%	            105357	            25	           50.81	        0.25	        363345.86	        8.99%	            7
    Blue Pen	    Stationery         4264	            4028690.06	                9.03%	            105870	            25	           50.77	        0.25	        410468.81	        10.19%	            8
    T-shirt	        Apparel            4268	            3996341.79	                8.95%	            105784	            25	           50.54	        0.25	        393981.95	        9.86%	            9
    Office Chair	Furniture          4301	            3987498.30	                8.93%	            106794	            25	           49.83	        0.25	        362592.31	        9.09%	            10
    Notebook	    Stationery         4230	            3986598.41	                8.93%	            104555	            25	           50.50	        0.25	        405447.85	        10.17%	            11
    
Business Insights
    1. All the 11 products across categories, generated a total revenue 
    ranging from 3.9 million to nearly 4.2 million. White Mug (Accessories) contributed 
    the highest revenue of 4.1 million or 9.39% share of the total revenue. Revenue 
    shares from all products contribute a relatively close percentage ranging from 
    8.93% to 9.39%. Although some variation exists, return rates generally clustered 
    around 9-10%, suggesting that no products experienced disproportionately high return 
    behavior.


*/

-- 7. How do products rank according to revenue within each category?


WITH revenue_perccnp AS(
    SELECT
           category,
           description,
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS totalrevenue_perccnp,
           CONCAT(ROUND(COUNT(CASE WHEN returnstatus = 'Returned' THEN 1 END)*100.0 /
        (COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)),2), '%') AS return_rate
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY category, description
)

SELECT 
    category,
    description,
    DENSE_RANK() OVER(PARTITION BY category ORDER BY totalrevenue_perccnp DESC),
    totalrevenue_perccnp,
    return_rate
FROM revenue_perccnp;

/*
Query Logic:
    1.Looking further into product ranking by category will give us an important insight on product
    performance and customer purchasing preferences.
Results:

    category	    description	    dense_rank	totalrevenue_perccnp	return_rate
    Accessories	    White Mug	        1	        4190846.23	            9.50%
    Accessories	    Backpack	        2	        4082019.31	            9.71%
    Apparel	        T-shirt	            1	        3996341.79	            10.05%
    Electronics	    USB Cable	        1	        4104764.70	            10.03%
    Electronics	    Wireless Mouse	    2	        4044009.38	            9.75%
    Electronics	    Headphones	        3	        4040060.59	            9.48%
    Furniture	    Desk Lamp	        1	        4099578.68	            9.59%
    Furniture	    Wall Clock	        2	        4073287.02	            10.09%
    Furniture	    Office Chair	    3	        3987498.30	            9.30%
    Stationery	    Blue Pen	        1	        4028690.06	            10.13%
    Stationery	    Notebook	        2	        3986598.41	            10.45%

Business Insights
    1. Top products per category were White Mug (Accessories), T-shirt (Apparel), USB Cable 
    (Electronics), Desk Lamp (Furniture), and Blue Pen (Stationery). Within each category
    revenues were fairly distributed and return rates were relatively consistent. 

*/
-- 8. How do products rank per country according to revenues?

WITH revenue_perccnp AS(
    SELECT
           country,
           description,
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS totalrevenue_perccnp,
           DENSE_RANK() OVER(PARTITION BY country ORDER BY 
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2)  DESC) AS product_rank
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY country, description
    
)

SELECT 
    country,
    description,
    totalrevenue_perccnp,
    product_rank
FROM revenue_perccnp
ORDER BY country, product_rank;

/*
Query Logic:
    1. This analysis will provide insight into how products rank per country
    according to revenues and customers' purchasing preferences per location.

Result:
    
    country	    description	    totalrevenue_perccnp	product_rank
    Australia	Blue Pen	        361071.07	            1
    Australia	Wall Clock	        342267.47	            2
    Australia	Backpack	        339675.56	            3
    Australia	Desk Lamp	        338883.45	            4
    Australia	White Mug	        338304.69	            5
    Australia	Wireless Mouse	    334016.37	            6
    Australia	Office Chair	    325966.96	            7
    Australia	USB Cable	        320712.91	            8
    Australia	Notebook	        318575.13	            9
    Australia	Headphones	        309806.72	            10
    Australia	T-shirt	            286781.71	            11

(Note: Other country's results were preferred not to be shown due to its lengthy coverage of results
congesting the project file.)

Business Insights:
    1. Customers' purchasing preferences from the whole year-coverage (2020-2025) were diversified 
    across different countries. White Mug led in four countries; Germany, Portugal, United Kingdom, 
    and United States. Desk Lamp is the top product in France and Norway while Office Chair in Belgium
    and Italy. Blue Pen is ranked first in Australia, USB Cable in Netherlands, Backpack in 
    Spain, and Notebook in Sweden. 

*/

-- 9. How do products rank according to country and year?


WITH revenue_perccnp AS(
    SELECT
           EXTRACT(YEAR FROM invoicedate) AS year,
           country,
           category,
           description,
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS totalrevenue_perccnp
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY EXTRACT(YEAR FROM invoicedate), country, category, description
)

SELECT 
    year,
    country,
    category,
    description,
    totalrevenue_perccnp,
    DENSE_RANK() OVER(PARTITION BY year, country ORDER BY totalrevenue_perccnp DESC) product_rank
FROM revenue_perccnp
GROUP BY year, country, category, description, totalrevenue_perccnp
ORDER BY year, country, totalrevenue_perccnp DESC;

------

WITH revenue_perccnp AS(
    SELECT
           EXTRACT(YEAR FROM invoicedate) AS year,
           country,
           category,
           description,
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS totalrevenue_perccnp,
           DENSE_RANK() OVER(PARTITION BY EXTRACT(YEAR FROM invoicedate), country ORDER BY 
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2)  DESC) product_rank
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY EXTRACT(YEAR FROM invoicedate), country, category, description
)

SELECT 
    year,
    country,
    category,
    description,
    totalrevenue_perccnp
FROM revenue_perccnp
WHERE product_rank = 1
GROUP BY year, country, category, description, totalrevenue_perccnp
ORDER BY year, country, totalrevenue_perccnp DESC;


/*
Query Logic:
    1. This analysis is a continuation of Query No. 8 which will look closely into 
    product revenue rankings per country over time.

Result:
    1.
    year	country	    category	description	    totalrevenue_perccnp	product_rank
    2020	Australia	Apparel	    T-shirt	           70315.58	                1
    2020	Australia	Stationery	Blue Pen	       64489.37	                2
    2020	Australia	Furniture	Office Chair	   61449.69	                3
    2020	Australia	Electronics	USB Cable	       59421.91	                4
    2020	Australia	Accessories	Backpack	       58892.32	                5
    2020	Australia	Accessories	White Mug	       55662.33	                6
    2020	Australia	Furniture	Wall Clock	       54289.21	                7
    2020	Australia	Electronics	Wireless Mouse	   48998.87	                8
    2020	Australia	Furniture	Desk Lamp	       48741.36	                9
    2020	Australia	Stationery	Notebook	       47041.03	                10
    2020	Australia	Electronics	Headphones	       45379.77	                11

    2. (Top Product for Every Country in 2020)
    year	country	            category	    description	    totalrevenue_perccnp
    2020	Australia	        Apparel	        T-shirt	        70315.58
    2020	Belgium	            Electronics	    Headphones	    74113.54
    2020	France	            Stationery	    Blue Pen	    71600.19
    2020	Germany	            Furniture	    Wall Clock	    76863.06
    2020	Italy	            Furniture	    Office Chair	76611.65
    2020	Netherlands	        Accessories	    Backpack	    72138.93
    2020	Norway	            Accessories	    Backpack	    63200.17
    2020	Portugal	        Electronics	    Wireless Mouse	68852.84
    2020	Spain	            Electronics	    USB Cable	    82646.53
    2020	Sweden	            Electronics	    USB Cable	    68733.16
    2020	United Kingdom	    Electronics	    USB Cable	    66053.16
    2020	United States	    Accessories	    White Mug	    85106.40

Business Insights:
    
    1. Product ranking per country over each year of coverage was not dominated by a 
    single product suggesting diversed customer purchasing preferences over time. 
    Moreover, product revenues generated per country over time displayed relatively 
    consistent values with very minimal high or low revenue values based on separate 
    Z-score tests.

*/ 
    

-- ====================================================================
--                          REVENUE X COUNTRY
-- ====================================================================


-- 10. How do countries rank according to revenue (demand location)?


WITH revenue_percountry AS(
    SELECT country,
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS total_revenue_percountry,
           COUNT(*) AS transactions
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY country
),

total_revenue AS(
    SELECT 
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS total_revenue
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
)
SELECT 
    RANK() OVER(ORDER BY total_revenue_percountry DESC) AS revenue_rank,
    rc.country,
    rc.total_revenue_percountry,
    rc.transactions,
    CONCAT(ROUND((rc.total_revenue_percountry*100.0/tr.total_revenue),2), '%') AS revenue_share
FROM revenue_percountry rc
CROSS JOIN total_revenue tr
ORDER BY total_revenue_percountry DESC;

/*

Query Logic:
    1. Knowing the revenue of each country will provide an insight on each country's revenue
    share on the total revenue.

Results:

revenue_rank	country	            total_revenue_percountry	transactions	revenue_share
    1	        Belgium	                    3834826.11	            3963	        8.59%
    2	        United Kingdom	            3796475.89	            3973	        8.51%
    3	        United States	            3784707.07	            3880	        8.48%
    4	        Sweden	                    3772469.00	            3994	        8.45%
    5	        Germany	                    3752836.92	            3972	        8.41%
    6	        France	                    3747060.16	            4021	        8.40%
    7	        Spain	                    3705806.58	            3897	        8.30%
    8	        Portugal	                3703387.87	            3959	        8.30%
    9	        Norway	                    3684369.20	            3938	        8.25%
    10	        Italy	                    3662175.87	            3845	        8.20%
    11	        Australia	                3616062.04	            3894	        8.10%
    12	        Netherlands	                3573517.75	            3957	        8.01%

Business Insights:
    1. According to revenue, Belgium ranked first with an 8.59% (3.83 million) revenue share.
    Moreover, revenues generated for each country showed minimal variations ranging closely between 
    3.6 million to 3.83 million with revenue shares clustered between 8.01% to 8.59%. These results
    suggest balnced revenue distribution across countries.

*/



-- 11. For every country, what is the top category and top product?


-- CTE 1: Revenue by Country + Category

WITH revenue_percc AS(
    SELECT country,
           category,
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS totalrevenue_percc
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY country, category
),

-- CTE 2: Rank Categories within each Country

rankcat_percountry AS(
    SELECT country,
           category,
           totalrevenue_percc,
           RANK() OVER(PARTITION BY country ORDER BY totalrevenue_percc DESC) AS rankcategory_percountry
    FROM revenue_percc
),

--CTE 5: Top rank per category
topcategory_percountry AS(
    SELECT country,
           category,
           totalrevenue_percc
    FROM rankcat_percountry
    WHERE rankcategory_percountry = 1
),

--CTE 6: Revenue by Country + Category + Product

revenue_perccnp AS(
    SELECT country,
           category,
           description,
           ROUND(SUM((quantity * unitprice) * (1 - discount)), 2) AS totalrevenue_perccnp
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY country, category, description
),

--CTE 7: Rank Products within each Country-Category

rankpro_percc AS(
    SELECT country,
           category,
           description,
           totalrevenue_perccnp,
           DENSE_RANK() OVER(PARTITION BY country,category ORDER BY totalrevenue_perccnp DESC) AS rankpro_percountrycategory
    FROM revenue_perccnp
),

--CTE 8: Top rank per product
topproduct_percountry AS(
    SELECT country,
           category,
           description,
           totalrevenue_perccnp
    FROM rankpro_percc
    WHERE rankpro_percountrycategory = 1
)

-- Final Query: country + top category + top product + total revenue

SELECT
    tc.country,
    tc.category,
    tp.description,
    tc.totalrevenue_percc,
    tp.totalrevenue_perccnp
FROM topcategory_percountry tc
INNER JOIN topproduct_percountry tp
ON tc.country = tp.country
AND tc.category = tp.category;


/*

Query Logic:
    1. This analysis will help us evaluate the top categories and top products
    per country.

Result:
    
    country	        category	    description	        totalrevenue_percc	    totalrevenue_perccnp
    Australia	    Furniture	    Wall Clock	            1007117.88	            342267.47
    Belgium	        Furniture	    Office Chair	        1074271.57	            379417.17
    France	        Electronics	    Headphones	            1051559.58	            369689.31
    Germany	        Furniture	    Wall Clock	            1034771.13	            357401.90
    Italy	        Furniture	    Office Chair	        1012304.91	            379990.97
    Netherlands	    Electronics	    USB Cable	            996408.32	            354414.70
    Norway	        Electronics	    Headphones	            1026309.19	            345554.31
    Portugal	    Furniture	    Wall Clock	            1012743.11	            378584.80
    Spain	        Electronics	    USB Cable	            1046242.06	            353007.46
    Sweden	        Electronics	    Headphones	            1054250.52	            358200.05
    United Kingdom	Furniture	    Office Chair	        1056360.37	            376682.04
    United States	Electronics	    Wireless Mouse	        1033149.70	            347250.68

Business Insights:
    1. Furniture and Electronics were the top categories each preferred accordingly by six countries.
     Revenues by the top categories spread roughly across 1 million and revenues by the top products of 
     the top category ranges between 345K to 380K. Moreover, results showed that Furniture and Electronics 
     having more products than the rest of categories is associated with higher revenue.


*/


-- ====================================================================
--                       REVENUE X SALES CHANNEL
-- ====================================================================


-- 12. Which sales channel contributes the largest share of total revenue?


WITH revenue_persaleschannel AS (
    SELECT 
        saleschannel,
        COUNT(*) AS transactions,
        COUNT(CASE WHEN returnstatus = 'Returned' THEN 1 END) AS returns,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS totalrevenue_persaleschannel
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    GROUP BY saleschannel

),

total_revenue AS (
    SELECT 
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS totalrevenue
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'

)

SELECT 
    saleschannel,
    totalrevenue,
    totalrevenue_persaleschannel,
    transactions,
    returns,
    ROUND(totalrevenue_persaleschannel / transactions, 2) AS avg_revenue_per_transaction,
    CONCAT(ROUND((totalrevenue_persaleschannel/ totalrevenue)*100, 2),'%') AS revenue_percentage,
    RANK() OVER(ORDER BY totalrevenue_persaleschannel DESC) AS revenue_rank
FROM revenue_persaleschannel
CROSS JOIN total_revenue

/*
Query Logic:
    1. This query will look upon the revenue performance based on sales channel and assess
    whether the mode of transaction influences revenue generation.

Results:

    saleschannel	totalrevenue	totalrevenue_persaleschannel	transactions	returns	avg_revenue_per_transaction	revenue_percentage	revenue_rank
    Online	        44633694.47	        22370864.19	                    23762	      2325	        941.46	                50.12%	             1
    In-Store	    44633694.47	        22262830.28	                    23531	      2321	        946.11	                49.88%	             2

Business Insights:

    1. Sales channel revenue shares minimal point difference with each other. Online sales channel has 
    a revenue share of 50.12% slightly higher than in-store with 49.88% revenue share. Transactions were 
    also higher in Online but slightly lower in average revenue per transaction (941.46) than the In-Store (946.11).
    Moreover, results suggests that the revenue share appears to be driven by the number of transactions.
    
*/


-- ====================================================================
--                         SECTION KEY FINDINGS
-- ====================================================================

/* 
    1.Total Revenue - 44.63 million
      Revenue from returns - 4.36 million
      Return rate - 9.76%

    2. Revenue gap between products within the same category is relatively small.
    Moreover, product demands is distributed across multiple products rather than being 
    concentrated in a single product line.

    3. Higher revenue categories appears to be associated with the number of products under it.

    4. Revenue share is minimally influenced by sales channel.

    5. Customers' product preferences is diversified per country over time.

    6. The noticeable point anomaly in September 2025 is driven by a data coverage issue. 

    7. Overall, the business exhibits stable and well-distributed revenue performance 
    across time, products, countries, and sales channels. There is no major structural imbalances, 
    suggesting opportunities for optimization may lie in product assortment, pricing, or customer 
    segmentation rather than broad operational changes.
*/

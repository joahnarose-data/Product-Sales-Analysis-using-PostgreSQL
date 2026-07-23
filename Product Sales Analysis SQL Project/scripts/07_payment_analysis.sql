
-- =====================================================================
--                  SQL PROJECT 1: PRODUCT SALES ANALYSIS
--                      SECTION 7: PAYMENT ANALYSIS
-- =====================================================================

-- 1. Which payment methods are most preferred by customers?

WITH paymentmethod_summary AS (
    SELECT 
        paymentmethod,
        COUNT(*) AS transaction_count,
        SUM(quantity) AS purchase_count,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    AND returnstatus = 'Not Returned'
    GROUP BY paymentmethod
)
SELECT 
    paymentmethod,
    CONCAT(ROUND(((transaction_count*100.0)/(SUM(transaction_count) OVER())),2),'%') AS usage_percentage,
    transaction_count,
    DENSE_RANK() OVER(ORDER BY transaction_count DESC) AS transactioncount_rank,
    purchase_count,
    DENSE_RANK() OVER(ORDER BY purchase_count DESC) AS purchasecount_rank,
    revenue,
    DENSE_RANK() OVER(ORDER BY revenue DESC) AS revenue_rank
FROM paymentmethod_summary;

/*

Query Logic:
    1. This analysis identifies all the payment methods used by customers and their supporting
    metrics to evaluate customers' preferences on payment methods.

Result:
    
    paymentmethod	usage_percentage	transaction_count	transactioncount_rank	purchase_count	purchasecount_rank	revenue	    revenue_rank
    Bank Transfer	    33.62%	            14340	                1	                358252	            1	       13639343.90	    1
    Credit Card	        33.29%	            14199	                2	                353965	            2	       13356881.32	    2
    Paypall	            33.08%	            14108	                3	                348997	            3	       13281873.45	    3


Business Insights:
    1. Payment methods utilized by customers are Bank Transfer, Credit Card, and Paypall.
    Among these three payment methods, Bank Transfer has the highest customer usage
    by just 0.33 percentage points from Credit Card having 33.29% and 0.54 percentage 
    points from Paypall having 33.08%. Bank Transfer also leads on transaction count, 
    overall product purchase, and revenue. While Bank Transfer leads the ranking, 
    values across all payment methods are relatively close indicating that no payment 
    method clearly dominates customers' preferences.

*/


-- 2. Do top-payment method preferences differ by country?

WITH toppayment_method AS(
    SELECT 
        country,
        paymentmethod,
        COUNT(*) AS paymentmethod_count,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
        DENSE_RANK() OVER(PARTITION BY country ORDER BY COUNT(*) DESC) AS top_payment_method
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    AND returnstatus = 'Not Returned'
    GROUP BY country, paymentmethod
)
SELECT
    country,
    paymentmethod,
    revenue
FROM toppayment_method
WHERE top_payment_method = 1;


-- 2A. How do payment methods rank according to country preference?

WITH toppayment_method AS(
    SELECT 
        country,
        paymentmethod,
        COUNT(*) AS paymentmethod_count,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
        DENSE_RANK() OVER(PARTITION BY country ORDER BY COUNT(*) DESC) AS top_payment_method
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    AND returnstatus = 'Not Returned'
    GROUP BY country, paymentmethod
),
top_method AS(
SELECT
    country,
    paymentmethod,
    revenue
FROM toppayment_method
WHERE top_payment_method = 1
)
SELECT 
    paymentmethod,
    COUNT(*) AS countrypreference_count,
    CONCAT(ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER(), 2), '%') AS countrypreference_percentage,
    DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rank
FROM top_method
GROUP BY paymentmethod;

/*

Query Logic:
    1. This analysis will determine top payment methods per country and evaluate their
    rankings based on country top preference count.

Result:
    
    country	        paymentmethod	    revenue
    Australia	    Paypall	            1062462.34
    Belgium	        Credit Card	        1212908.48
    France	        Bank Transfer	    1146690.95
    Germany	        Bank Transfer	    1225369.68
    Italy	        Bank Transfer	    1117944.59
    Netherlands	    Bank Transfer	    1086421.32
    Norway	        Bank Transfer	    1141939.26
    Portugal	    Credit Card	        1129595.80
    Spain	        Bank Transfer	    1145971.60
    Sweden	        Paypall	            1106966.91
    United Kingdom	Bank Transfer	    1182696.34
    United States	Paypall	            1202857.68


    paymentmethod	countrypreference_count	countrypreference_percentage	rank
    Bank Transfer	        7	                    58.33%	                 1
    Paypall	                3	                    25.00%	                 2
    Credit Card	            2	                    16.67%	                 3


    Business Insights:
    1. Bank Transfer is the top payment method of more than half of the 12 countries
    which is 58.33% of country preference share. Results suggest that majority of countries
    rank Bank Transfer first.

*/

-- 3. Do payment preferences differ by category?

WITH toppayment_method AS(
    SELECT 
        category,
        paymentmethod,
        COUNT(*) AS transaction_count,
        DENSE_RANK() OVER(PARTITION BY category ORDER BY COUNT(*) DESC) AS transactioncount_rank,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
        DENSE_RANK() OVER(PARTITION BY category ORDER BY 
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) DESC) AS revenue_rank
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    AND returnstatus = 'Not Returned'
    GROUP BY category, paymentmethod
    ORDER BY category, transactioncount_rank
)
SELECT
    category,
    paymentmethod,
    transaction_count,
    CONCAT(ROUND(((transaction_count*100.0)/(SUM(transaction_count) OVER(PARTITION BY category))),2), '%') AS transaction_percentage,
    transactioncount_rank,
    revenue,
    revenue_rank
FROM toppayment_method;


/*

Query Logic:
    1. This analysis will evaluate whether product categories have an association
    with payment preferences.

Result:
    
    category	    paymentmethod	transaction_count	transaction_percentage	transactioncount_rank	revenue	    revenue_rank
    Accessories	    Bank Transfer	      2662	                33.95%	                1	            2566061.04	    1
    Accessories	    Credit Card	          2605	                33.23%	                2	            2488131.19	    2
    Accessories	    Paypall	              2573	                32.82%	                3	            2413589.74	    3
    Apparel	        Credit Card	          1297	                33.78%	                1	            1193630.54	    3
    Apparel	        Bank Transfer	      1278	                33.29%	                2	            1201144.92	    2
    Apparel	        Paypall	              1264	                32.93%	                3	            1207584.38	    1
    Electronics	    Credit Card	          3896	                33.58%	                1	            3644548.79	    3
    Electronics	    Bank Transfer	      3861	                33.28%	                2	            3695280.16	    1
    Electronics	    Paypall	              3846	                33.15%	                3	            3653861.70	    2
    Furniture	    Bank Transfer	      3950	                33.63%	                1	            3686691.40	    1
    Furniture	    Credit Card	          3902	                33.22%	                2	            3645622.75	    3
    Furniture	    Paypall	              3893	                33.15%	                3	            3682580.22	    2
    Stationery	    Bank Transfer	      2589	                33.98%	                1	            2490166.38	    1
    Stationery	    Paypall	              2532	                33.23%	                2	            2324257.40	    3
    Stationery	    Credit Card	          2499	                32.80%	                3	            2384948.04	    2


Business Insights:
    1. Results show fairly distributed transaction percentage across payment methods from all categories
    ranging at approximately 32% to 33%. This suggest that categories has minimal association on 
    payment preferences. 

*/


-- 4. How do payment methods rank according to preferences across online/in-store purchase?

SELECT
    saleschannel,
    paymentmethod,
    COUNT(*) AS transaction_count,
    DENSE_RANK() OVER(PARTITION BY saleschannel ORDER BY COUNT(*) DESC) AS transactioncount_rank,
    ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
    DENSE_RANK() OVER(PARTITION BY saleschannel ORDER BY 
    ROUND(SUM((quantity * unitprice) * (1 - discount)),2) DESC) AS revenue_rank,
    SUM(quantity) AS purchase_count,
    DENSE_RANK() OVER(PARTITION BY saleschannel ORDER BY SUM(quantity) DESC) AS purchasecount_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
AND returnstatus = 'Not Returned'
GROUP BY saleschannel, paymentmethod;

-- 4A. Which payment methods generate the highest average transaction value?
SELECT
    paymentmethod,
    ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS Revenue,
    COUNT(*) AS transaction_count,
    ROUND(SUM((quantity * unitprice) * (1 - discount))/(COUNT(*)),2) AS averagepertransaction_value,
    RANK() OVER(ORDER BY ROUND(SUM((quantity * unitprice) * (1 - discount))/(COUNT(*)),2) DESC) AS averagepertransaction_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
AND returnstatus = 'Not Returned'
GROUP BY paymentmethod;


/*

Query Logic:
    1. This analysis will evaluate the rankings of payment method in online and in-store channels
    and also determine their corresponding average transaction value.

Result:
    
    saleschannel	paymentmethod	transaction_count	transactioncount_rank	revenue	        revenue_rank	purchase_count	purchasecount_rank
    In-Store	    Bank Transfer	    7121	                1	            6788647.40	          1	            178394	            1
    In-Store	    Credit Card	        7075	                2	            6670045.90	          3	            177234	            2
    In-Store	    Paypall	            7014	                3	            6675856.78	          2	            173403	            3
    Online	        Bank Transfer	    7219	                1	            6850696.49	          1	            179858	            1
    Online	        Credit Card	        7124	                2	            6686835.41	          2	            176731	            2
    Online	        Paypall	            7094	                3	            6606016.67	          3	            175594	            3


    paymentmethod	revenue	    transaction_count	averagepertransaction_value	averagepertransaction_rank
    Bank Transfer	13639343.90	    14340	                951.14	                        1
    Paypall	        13281873.45	    14108	                941.44	                        2
    Credit Card	    13356881.32	    14199	                940.69	                        3


Business Insights:
    1. Bank Transfer ranked first among all payment methods on both Online and In-Store channels
    based on transaction counts, revenue, and volume of purchase. It also ranks first in average 
    transaction value and overall revenue across both channels. Corresponding values across the three 
    payment methods have relatively small differences suggesting that customer preferences are broadly 
    distributed across the three payment methods, with no single payment method clearly dominating usage.

*/


-- 5. Does order priority affect payment method preference

WITH choice_count AS(
    SELECT 
    orderpriority,
    paymentmethod,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END) AS preference_count,
    DENSE_RANK() OVER(PARTITION BY orderpriority ORDER BY COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END) DESC) 
        AS preference_rank
FROM product_sales_clean
GROUP BY orderpriority, paymentmethod
)
SELECT
    orderpriority,
    paymentmethod,
    preference_rank,
    preference_count
FROM choice_count
ORDER BY CASE orderpriority
    WHEN 'High' THEN 1
    WHEN 'Medium' THEN 2
    WHEN 'Low' THEN 3
    ELSE 4
END ASC;

/*

Query Logic:
    1. This analysis will evaluate whether order priority has a potential 
    association on payment method preference.

Result:
    
    orderpriority	paymentmethod	preference_rank	preference_count
        High	    Credit Card	        1	            5298
        High	    Paypall	            2	            5266
        High	    Bank Transfer	    3	            5199
        Medium	    Paypall	            3	            5201
        Medium	    Bank Transfer	    1	            5357
        Medium	    Credit Card	        2	            5264
        Low	        Bank Transfer	    1	            5377
        Low	        Paypall	            2	            5172
        Low	        Credit Card	        3	            5159


Business Insights:
    1. Leading payment methods across three order priorities are diverse.
    Credit Card ranked first in 'High' order priority, and Bank Transfer in 
    'Medium' and 'Low' order priority. Preference counts in each of the payment 
    methods across order priorities have minimal differences ranging from 
    approximately 5.2K to 5.4K. The relatively consistent distribution of 
    preference counts suggests that an association between order priority and 
    choice of payment method is minimal.

*/




-- ====================================================================
--                         SECTION KEY FINDINGS
-- ====================================================================

/*

    1. Bank Transfer consistently ranked first across transaction count, total product
purchases, and revenue. It also ranked first in both Online and In-Store purchases
and was the most preferred payment method in seven out of the twelve countries
analyzed. Despite leading across multiple business metrics, differences among the
three payment methods remained small, indicating that customer payment preferences
are broadly distributed with no clear dominant payment method.

2. Payment method preferences remain relatively consistent across product categories.
Transaction shares for Bank Transfer, Credit Card, and PayPal are closely distributed
within each category, suggesting that product categories have minimal association
with customers' choice of payment method.

3. Payment method rankings vary across order priorities, with Credit Card leading
High-priority orders while Bank Transfer leads Medium- and Low-priority orders.
However, preference counts remain relatively close across all payment methods,
suggesting no clear association between order priority and customers' payment
method preferences.

*/
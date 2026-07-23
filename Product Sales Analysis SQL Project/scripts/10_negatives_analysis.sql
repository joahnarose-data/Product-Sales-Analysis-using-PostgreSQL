
-- =====================================================================
--                  SQL PROJECT 1: PRODUCT SALES ANALYSIS
--                     SECTION 10: NEGATIVES ANALYSIS
-- =====================================================================

-- 1. What percentage of all transactions are negative transactions?

SELECT
    COUNT(*) AS overall_transactions,
    COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negative_transactions,
    CONCAT(ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
    /
    NULLIF(COUNT(*),0),2),'%') AS negative_transactionpercentage
FROM product_sales_clean

/*

Query Logic:
    1. This analysis will determine the overall transaction count, negative transaction count,
    and its percentage. 

Result:
    
    overall_transactions	negative_transactions	negative_transactionpercentage
            49782	                2489	                    5.00%


Business Insights:

    1. Out of 49, 782 total transactions, 47, 293 (95%) are positive transactions, while
    2, 489 (5%) are negative transactions. This indicates that negative transactions 
    represent a relatively samll proportion of the overall dataset. The succeeding 
    analyses focus on understanding the characteristics and potential patterns associated
    with these negative transactions.

*/


-- 2. Which categories have the highest negative transaction rates?

WITH categories AS(
    SELECT 
        category,
        COUNT(*) AS overall_transactions,
        COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negative_transactions_count,
        CONCAT(ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2),'%') AS negative_transactionpercentage,
        DENSE_RANK() OVER(ORDER BY ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) DESC) AS negative_transactionrate_rank
    FROM product_sales_clean
    GROUP BY category
)
 SELECT
    category,
    overall_transactions,
    negative_transactions_count,
    negative_transactionpercentage,
    negative_transactionrate_rank
FROM categories

/*

Query Logic:
    1. This analysis will layout all the categories and their corresponding negative 
    transaction rates then ranks them accordingly from highest to lowest.

Result:
    
    category	overall_transactions	negative_transactions_count	negative_transactionpercentage	negative_transactionrate_rank
  Electronics	    13583	                    726	                            5.34%	                        1
  Stationery	    8963	                    469	                            5.23%	                        2
  Furniture	        13684	                    683	                            4.99%	                        3
  Accessories	    9086	                    413	                            4.55%	                        4
  Apparel	        4466	                    198	                            4.43%	                        5


Business Insights:

    1. Electronics recorded the highest negative transaction rate (5.34%), followed closely by
    Stationery, Furniture, Accessories, and Apparel. Negative transaction rates across all 
    categories range from 4.43% to 5.34%, representing less than a one-percentage-point 
    difference. This suggests that negative transactions are fairly evenly distributed across
    product categories, with no category exhibiting a substantially higher negative transaction rate
    than the others. While no immediate category-specific concern is evident, continued monitoring 
    of negative transactions remains appropriate. 

*/


-- 3. Which products generate the most negative transaction rates?

WITH description AS(
    SELECT 
        description,
        COUNT(*) AS overall_transactions,
        COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negative_transactions_count,
        CONCAT(ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2),'%') AS negative_transactionrate,
        DENSE_RANK() OVER(ORDER BY ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) DESC) AS negative_transactionrate_rank
    FROM product_sales_clean
    GROUP BY description
)
 SELECT
    description,
    overall_transactions,
    negative_transactions_count,
    negative_transactionrate,
    negative_transactionrate_rank
FROM description

/*

Query Logic:
    1.  This analysis will layout all the products and their 
    corresponding negative transaction rates then ranks them 
    accordingly from highest to lowest.

Result:
    
    description	overall_transactions	negative_transactions_count	negative_transactionrate	negative_transactionrate_rank
    Headphones	        4555	                273	                        5.99%	                        1
    Wall Clock	        4617	                255	                        5.52%	                        2
    Blue Pen	        4509	                245	                        5.43%	                        3
    Wireless Mouse	    4448	                232	                        5.22%	                        4
    Notebook	        4454	                224	                        5.03%	                        5
    Office Chair	    4522	                221	                        4.89%	                        6
    USB Cable	        4580	                221	                        4.83%	                        7
    White Mug	        4536	                218	                        4.81%	                        8
    Desk Lamp	        4545	                207	                        4.55%	                        9
    T-shirt	            4466	                198	                        4.43%	                        10
    Backpack	        4550	                195	                        4.29%	                        11


Business Insights:

    1. Negative transaction rates across products remain relatively close, ranging from 4.29% to 5.99%,
    representing a spread of only 1.70 percentage points between the highest and lowest rates. Headphones
    recorded the highest negative transaction rate, while Backpack recorded the lowest. Consistent with 
    previous analyses, the results provide no strong evidence that any single product experiences a 
    substantially higher negative transaction rate than the others.

*/

-- 4. Are online purchases more likely to become negative transactions than in-store purchases?

WITH saleschannels AS(
    SELECT 
        saleschannel,
        COUNT(*) AS overall_transactions,
        COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negative_transactions_count,
        ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) AS negative_transactionpercentage,
        DENSE_RANK() OVER(ORDER BY ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) DESC) AS negative_transactionrate_rank
    FROM product_sales_clean
    GROUP BY saleschannel
)
 SELECT
    saleschannel,
    overall_transactions,
    negative_transactions_count,
    negative_transactionpercentage,
    negative_transactionrate_rank
FROM saleschannels

/*

Query Logic:

    1. This analysis evaluates whether sales channel is associated with the occurence of negative transactions.

Result:
    
    saleschannel	overall_transactions	negative_transactions_count	negative_transactionpercentage	negative_transactionrate_rank
    Online	            25051	                        1289	                    5.15	                            1
    In-Store	        24731	                        1200	                    4.85	                            2


Business Insights:

    1. Online purchases recorded a slightly higher negative transaction rate (5.15%) than In-Store
    purchases (4.85%), representing a difference of only 0.30 percentage points. Despite Online ranking first, 
    the negative transaction rates across both sales channels remain very similar. These findings suggest no 
    strong evidence that sales channel is substantially associated with the occurence of negative transactions. 

*/


-- 5. Which countries have the highest negative transaction rates?

WITH countries AS(
    SELECT 
        country,
        COUNT(*) AS overall_transactions,
        COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negative_transactions_count,
        CONCAT(ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2),'%') AS negative_transactionpercentage,
        DENSE_RANK() OVER(ORDER BY ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) DESC) AS negative_transactionrate_rank
    FROM product_sales_clean
    GROUP BY country
)
 SELECT
    country,
    overall_transactions,
    negative_transactions_count,
    negative_transactionpercentage,
    negative_transactionrate_rank
FROM countries


/*

Query Logic:
    1. This analysis will layout all the countries and their 
    corresponding negative transaction rates then ranks them 
    accordingly from highest to lowest.

Result:
    
    country	    overall_transactions	negative_transactions_count	negative_transactionpercentage	negative_transactionrate_rank
    Norway	            4157	                219	                            5.27%	                        1
    Australia	        4110	                216	                            5.26%	                        2
    Netherlands	        4173	                216	                            5.18%	                        3
    Sweden	            4211	                217	                            5.15%	                        4
    Germany	            4182	                210	                            5.02%	                        5
    Italy	            4048	                203	                            5.01%	                        6
    Belgium	            4170	                207	                            4.96%	                        7
    United Kingdom	    4180	                207	                            4.95%	                        8
    Spain	            4100	                203	                            4.95%	                        8
    France	            4230	                209	                            4.94%	                        9
    Portugal	        4163	                204	                            4.90%	                        10
    United States	    4058	                178	                            4.39%	                        11


Business Insights:

    1. Among the 12 countries, Norway recorded the highest negative transaction rate (5.27%), while the
    United States recorded the lowest (4.39%). This represents a spread of only 0.88 percentage points
    between the highest and lowest rates. Overall, negative transaction rates remain relatively consistent
    across countries, providing no strong evidence that negative transactions are disproportionately 
    concetrated in any single market.

*/

-- 6. Which payment methods are associated with the highest negative transaction rates?

WITH paymentmethods AS(
    SELECT 
        paymentmethod,
        COUNT(*) AS overall_transactions,
        COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negative_transactions_count,
        ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) AS negative_transactionpercentage,
        DENSE_RANK() OVER(ORDER BY ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) DESC) AS negative_transactionrate_rank
    FROM product_sales_clean
    GROUP BY paymentmethod
)
 SELECT
    paymentmethod,
    overall_transactions,
    negative_transactions_count,
    negative_transactionpercentage,
    negative_transactionrate_rank
FROM paymentmethods

/*

Query Logic:
    1. This analysis will determine the payment methods and ranks them according to 
    their negative transaction rates.

Result:
    
    paymentmethod	overall_transactions	negative_transactions_count	negative_transactionpercentage	negative_transactionrate_rank
    PayPal	            16505	                    866	                            5.25	                            1
    Credit Card	        16530	                    809	                            4.89	                            2
    Bank Transfer	    16747	                    814	                            4.86	                            3


Business Insights:

    1. PayPal recorded the highest negative transaction rate (5.25%), followed by Credit Card (4.89%)
    and Bank Transfer (4.86%). The difference between the highest and lowest rates is only 0.39
    percentage points, indicating that negative transactions are relatively evenly distributed across
    payment methods. These findings provide no strong evidence that any payment method experiences a 
    substantially higher negative transaction rate than the others.

*/

-- 7. Does discount level influence negative transaction rates?

WITH discounts AS(
    SELECT 
        CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.10 THEN 'Low Discount'
        WHEN discount <= 0.20 THEN 'Medium Discount'
        ELSE 'High Discount'
        END AS discount_level,
        COUNT(*) AS overall_transactions,
        COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negative_transactions_count,
        CONCAT(ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2),'%') AS negative_transactionpercentage,
        DENSE_RANK() OVER(ORDER BY ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) DESC) AS negative_transactionrate_rank
    FROM product_sales_clean
    GROUP BY discount_level
)
 SELECT
    discount_level,
    overall_transactions,
    negative_transactions_count,
    negative_transactionpercentage,
    negative_transactionrate_rank
FROM discounts


/*

Query Logic:

    1. This analysis evaluates negative transaction rates across discount levels to determine whether
    discounting is associated with the occurence of negative transactions.

Result:
    
    discount_level	overall_transactions	negative_transactions_count	negative_transactionpercentage	negative_transactionrate_rank
    High Discount	    29887	                        1919	                    6.42%	                            1
    Medium Discount	    9751	                        292	                        2.99%	                            2
    Low Discount	    9646	                        266	                        2.76%	                            3
    No Discount	        498	                            12	                        2.41%	                            4


Business Insights:

    1. High Discount transactions recorded the highest negative transaction rate (6.42%), substantially exceeding 
    Medium (2.99%), Low (2.76%), and No Discount (2.41%). Unlike previous analyses where differences between groups
    were minimal, this result shows a noticeably wider spread of 4.01 percentage-points between the highest and 
    lowest rates. these findings suggest that transactions involving higher discounts may be associated with a 
    greater likelihood of becoming negative transactions. However, this analysis identifies an association rather than
    causation, and additional investigation is needed to determine the underlying drivers.

*/


-- 8. Which shipment providers are associated with the highest negative transaction rates?


WITH shipments AS(
    SELECT 
        shipmentprovider,
        COUNT(*) AS overall_transactions,
        COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negative_transactions_count,
        CONCAT(ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2),'%') AS negative_transactionpercentage,
        DENSE_RANK() OVER(ORDER BY ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) DESC) AS negative_transactionrate_rank
    FROM product_sales_clean
    GROUP BY shipmentprovider
)
 SELECT
    shipmentprovider,
    overall_transactions,
    negative_transactions_count,
    negative_transactionpercentage,
    negative_transactionrate_rank
FROM shipments


/*

Query Logic:

    1. This analysis evaluates the negative transaction rates across shipment providers to
    identify whether any provider is associated with a relatively higher share of negative
    transactions.

Result:
    
    shipmentprovider	overall_transactions	negative_transactions_count	negative_transactionpercentage	negative_transactionrate_rank
        UPS	                    12433	                    654	                        5.26%	                        1
        DHL	                    12425	                    629	                        5.06%	                        2
        Royal Mail	            12423	                    607	                        4.89%	                        3
        FedEx	                12501	                    599	                        4.79%	                        4


Business Insights:

    1. Negative transaction rates across all shipment providers range from 4.79% to 5.26%, a spread of 
    only 0.47 percentage points. UPS recorded the highest negative transaction rate (5.26%), followed by
    DHL (5.06%), Royal Mail (4.89%), and FedEx (4.79%). Despite UPS ranking first, the relatively small
    differences in negative transaction rates indicate that negative transactions are fairly distributed 
    across shipment providers, suggesting no single provider exhibits a substantially higher negative 
    transaction rate.
*/


-- 9. Which warehouse locations are associated with the highest negative transaction rates?

WITH warehouses AS(
    SELECT 
        warehouselocation,
        COUNT(*) AS overall_transactions,
        COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negative_transactions_count,
        ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) AS negative_transactionpercentage,
        DENSE_RANK() OVER(ORDER BY ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) DESC) AS negative_transactionrate_rank
    FROM product_sales_clean
    GROUP BY warehouselocation
)
 SELECT
    warehouselocation,
    overall_transactions,
    negative_transactions_count,
    negative_transactionpercentage,
    negative_transactionrate_rank
FROM warehouses


/*

Query Logic:

    1. This analysis evaluates warehouse locations according to their 
    negative transaction rates and ranks them from highest to lowest.

Result:
    
    warehouselocation	overall_transactions	negative_transactions_count	negative_transactionpercentage	negative_transactionrate_rank
    Unspecified	                3485	                    2489	                    71.42	                        1
    Amsterdam	                9458	                    0	                        0.00	                        2
    London	                    9230	                    0	                        0.00	                        2
    Paris	                    9173	                    0	                        0.00	                        2
    Berlin	                    9210	                    0	                        0.00	                        2
    Rome	                    9226	                    0	                        0.00	                        2


Business Insights:

     1. All 2, 489 negative transactions (5% of all transactions) are associated with the Unspecified 
     warehouse location, while all named warehouse locations recorded zero negative transactions. This
     pattern suggests that warehouse information is unavailable or intentionally assigned as "Unspecified"
     for negative transactions rather than indicating that the Unspecified warehouse itself generated all 
     negative transactions. Consequently, warehouse performance cannet be meaningfully evaluated using 
     negative transactions in this dataset.

*/


-- 10. Does order priority influence negative transaction rates?

WITH orders AS(
    SELECT 
        orderpriority,
        COUNT(*) AS overall_transactions,
        COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negative_transactions_count,
        ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) AS negative_transactionpercentage,
        DENSE_RANK() OVER(ORDER BY ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
        /
        NULLIF(COUNT(*),0),2) DESC) AS negative_transactionrate_rank
    FROM product_sales_clean
    GROUP BY orderpriority
)
 SELECT
    orderpriority,
    overall_transactions,
    negative_transactions_count,
    negative_transactionpercentage,
    negative_transactionrate_rank
FROM orders

/*

Query Logic:

    1. This analysis evaluates whether order priority is associated with differences in negative transaction rates.

Result:
    
    orderpriority	overall_transactions	negative_transactions_count	negative_transactionpercentage	negative_transactionrate_rank
    Medium	            16678	                    856	                            5.13	                        1
    Low	                16542	                    834	                            5.04	                        2
    High	            16562	                    799	                            4.82	                        3


Business Insights:

    1. Medium order priority recorded the highest negative transaction rate (5.13%), followed by Low (5.04%) and
    High (4.82%). The negative transaction rates differ by only 0.31 percentage points, indicating a relatively
    consistent distribution across all order priorities. These results suggest no clear association between order
    priority and the likelihood of negative transactions.

*/


-- 11. How much revenue is associated with negative transactions?


SELECT 
    COUNT(*) AS overall_transactions,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END) AS positive_transactions,
    ROUND(SUM(CASE WHEN transaction_status = 'Positive Transaction' THEN (quantity * unitprice) * (1 - discount) ELSE 0 END),2) AS revenue_positivetransactions,
    ROUND(COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)*100.0
    /
    NULLIF(COUNT(*),0),2) AS positive_transactionpercentage,
    COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END) AS negative_transactions,
    ABS(ROUND(SUM(CASE WHEN transaction_status = 'Negative Transaction'THEN (quantity * unitprice) * (1 - discount) ELSE 0 END),2)) AS revenue_negativetransaction,
    ROUND(COUNT(CASE WHEN transaction_status = 'Negative Transaction' THEN 1 END)*100.0
    /
    NULLIF(COUNT(*),0),2) AS negative_transactionpercentage,
    ROUND(ABS(SUM(CASE WHEN transaction_status = 'Negative Transaction' THEN (quantity * unitprice) * (1-discount) ELSE 0 END)) * 100.0
    /
    NULLIF(SUM(CASE WHEN transaction_status = 'Positive Transaction' THEN (quantity * unitprice) * (1-discount) ELSE 0 END),0),2) AS negative_revenue_loss_pct
FROM product_sales_clean


/*

Query Logic:

    1. This analysis compares revenue from positive transactions with the revenue value associated
    with negative transactions to estimate the percentage of revenue loss attributable to 
    negative transactions.

Result:
    
    overall_transactions	positive_transactions	revenue_positivetransactions	positive_transactionpercentage	negative_transactions	revenue_negativetransaction	negative_transactionpercentage	negative_revenue_loss_pct
            49782	                47293	                44633694.47	                        95.00	                    2489	                1122421.44	                    5.00	                        2.51


Business Insights:

    1. Positive transactions generated 44.63 million in revenue from 47, 293 transactions(95%), while 2, 489
    negative transactions (5%) represent an estimated 1.12 million in reversed or lost revenue. This corresponds to 
    2.51% of the revenue generated from positive transactions, suggesting that although negative transactions 
    account for 5% of all transactions, their associated revenue loss represents a relatively small share of total
    positive revenue.

*/


-- 12. What is the relationship between negative transactions and returns?


WITH status_summary AS (
    SELECT
        transaction_status,
        returnstatus,
        COUNT(*) AS transactions,
        ABS(ROUND(SUM((quantity * unitprice) * (1 - discount)),2)) AS total_revenue
    FROM product_sales_clean
    GROUP BY transaction_status, returnstatus
)

SELECT
    transaction_status,
    returnstatus,
    transactions,
    total_revenue,
    ROUND(
        transactions * 100.0
        /
        SUM(transactions) OVER(PARTITION BY transaction_status),
        2
    ) AS status_percentage
FROM status_summary
ORDER BY transaction_status, returnstatus;

/*

Query Logic:

    1. This analysis compares the distribution of returned and non-returned orders between 
    positive and negative transactions to determine whether transaction status is 
    associated with returns.

Result:
    
    transaction_status	    returnstatus	transactions	total_revenue	status_percentage
    Negative Transaction	Not Returned	    2241	      1032044.24	    90.04
    Negative Transaction	Returned	         248	        90377.20	    9.96
    Positive Transaction	Not Returned	    42647	     40278098.66	    90.18
    Positive Transaction	Returned	        4646	      4355595.81	    9.82


Business Insights:

    1. Negative transactions consist of 2,241 non-returned transactions (90.04%) and 248 returned
    transactions (9.96%), while positive transactions consist of 42, 647 non-returned transactions
    (90.18%) and 4, 646 returned transactions (9.82%). The returned proportions differ by only
    0.14 percentage points (9.96% vs. 9.82%), indicating that returned orders occur at nearly the 
    same rate regardless of transaction status. These results suggest no meaningful association
    between transaction status and the likelihood of a return.

*/


-- ====================================================================
--                         SECTION KEY FINDINGS
-- ====================================================================

/*

1. Negative transactions account for only 5% of the overall dataset, indicating
that unsuccessful transactions represent a relatively small portion of business
activity. Across product categories, products, sales channels, countries, payment
methods, shipment providers, and order priorities, negative transaction rates
remain relatively consistent with only small percentage-point differences.
These findings suggest that negative transactions are generally distributed across
the business rather than concentrated within a specific operational or customer
segment.

2. High Discount transactions are the only business factor showing a noticeably
higher negative transaction rate compared to the other groups analyzed. Unlike
the relatively consistent patterns observed across other business dimensions,
High Discount transactions recorded a substantially wider percentage-point
difference. These findings suggest a potential association between larger
discount offerings and the occurrence of negative transactions. However,
this analysis identifies an association rather than causation, and further
investigation is necessary to determine the underlying factors.

3. Although negative transactions account for 5% of all transactions, they
represent only 2.51% of the revenue generated from positive transactions,
indicating a relatively limited financial impact on the business. In addition,
returned purchases occur at nearly identical rates under both positive and
negative transaction statuses, suggesting no meaningful association between
transaction status and product returns. Finally, because all negative
transactions are assigned to the 'Unspecified' warehouse location, warehouse
performance cannot be reliably evaluated using negative transaction records
within this dataset.

*/
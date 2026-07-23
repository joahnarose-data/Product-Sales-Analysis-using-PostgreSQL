
-- =====================================================================
--                  SQL PROJECT 1: PRODUCT SALES ANALYSIS
--               SECTION 9: LOGISTICS AND OPERATIONS ANALYSIS
-- =====================================================================

-- 1. How do shipment providers rank according to transactions, quantity, and revenue for OVERALL purchases?

WITH transactions AS(
    SELECT 
    shipmentprovider,
        COUNT(*) AS transaction_count,
        DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS tc_rank
FROM product_sales_clean
WHERE transaction_status =  'Positive Transaction'     
AND returnstatus =  'Not Returned' 
GROUP BY shipmentprovider
),

quantity AS(
    SELECT
        shipmentprovider,
        SUM(quantity) AS quantity_count,
        DENSE_RANK() OVER(ORDER BY SUM(quantity) DESC) AS qc_rank  
    FROM product_sales_clean
    WHERE transaction_status =  'Positive Transaction'     
    AND returnstatus =  'Not Returned' 
    GROUP BY shipmentprovider
),

revenue AS(
    SELECT 
        shipmentprovider,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
        DENSE_RANK() OVER(ORDER BY ROUND(SUM((quantity * unitprice) * (1 - discount)),2) DESC) AS r_rank    
    FROM product_sales_clean
    WHERE transaction_status =  'Positive Transaction'     
    AND returnstatus =  'Not Returned' 
    GROUP BY shipmentprovider
)

SELECT 
    t.shipmentprovider,
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
INNER JOIN quantity q ON t.shipmentprovider = q.shipmentprovider
INNER JOIN revenue r ON t.shipmentprovider = r.shipmentprovider

/*

Query Logic:
    1. This analysis will determine all the shipment providers and rank them according to transactions,
    quantity, and revenue for overall purchase(online/in-store).

Result:

    shipmentprovider	transaction_count	tc_rank	quantity_count	qc_rank	revenue	        r_rank	overall_score	overall_rank
        FedEx	            10722	            1	    268478	        1	10200024.33	      1	        3	            1
        UPS	                10663	            2	    264549	        2	10061416.16	      2	        6	            2
        Royal Mail	        10645	            3	    264085	        4	10022827.27	      3	        10	            3
        DHL	                10617	            4	    264102	        3	9993830.91	      4	        11	            4
    


Business Insights:
    1. FedEx ranked first in transactions, total quantity of products sold, and overall revenue. It was followed
    by UPS, Royal Mail, then DHL. Values under transaction count are closely distributed ranging from 10,617
    to 10,722. For the quantity rank, FedEx leads at roughly 4K products ahead of the other three shipment 
    providers. Lastly, revenues range from 9.99 million to 10.2 million. Results suggest that customers' preference for
    shipment providers are fairly distributed. Despite FedEx leading the overall ranking, the relatively close values 
    under each metric suggest no clear dominance of shipment providers.

*/


-- 1A. How do shipment providers perform on ONLINE purchases according to transaction, quantity, and revenue?


WITH transactions AS(
    SELECT 
    shipmentprovider,
        COUNT(*) AS transaction_count,
        DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS tc_rank
FROM product_sales_clean
WHERE transaction_status =  'Positive Transaction'     
AND returnstatus =  'Not Returned' 
AND saleschannel = 'Online'
GROUP BY shipmentprovider
),

quantity AS(
    SELECT
        shipmentprovider,
        SUM(quantity) AS quantity_count,
        DENSE_RANK() OVER(ORDER BY SUM(quantity) DESC) AS qc_rank  
    FROM product_sales_clean
    WHERE transaction_status =  'Positive Transaction'     
    AND returnstatus =  'Not Returned' 
    AND saleschannel = 'Online'
    GROUP BY shipmentprovider
),

revenue AS(
    SELECT 
        shipmentprovider,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
        DENSE_RANK() OVER(ORDER BY ROUND(SUM((quantity * unitprice) * (1 - discount)),2) DESC) AS r_rank    
    FROM product_sales_clean
    WHERE transaction_status =  'Positive Transaction'     
    AND returnstatus =  'Not Returned' 
    AND saleschannel = 'Online'
    GROUP BY shipmentprovider
)

SELECT 
    t.shipmentprovider,
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
INNER JOIN quantity q ON t.shipmentprovider = q.shipmentprovider
INNER JOIN revenue r ON t.shipmentprovider = r.shipmentprovider

/*

Query Logic:
    1. This analysis will focus on evaluating the performance of shipment providers in online purchases
    according to transaction, quantity, and revenue.

Result:
    
    shipmentprovider	transaction_count	tc_rank	quantity_count	qc_rank	    revenue	    r_rank	overall_score	overall_rank
        UPS	                5408	          1	        133751	        1	    5020825.90	    3	    5	            1
        FedEx	            5344	          3	        132986	        2	    5083951.53	    1	    6	            2
        Royal Mail	        5355	          2	        132710	        4	    5027835.01	    2	    8	            3
        DHL	                5330	          4	        132736	        3	    5010936.14	    4	    11	            4


Business Insights:
    1. UPS ranked first in overall online purchases followed by FedEx, Royal Mail, then DHL.
    Transaction and quantiy counts across all shipment providers are relatively close. Moreover, 
    revenue values range at roughly 5 million to 5.1 million with FedEx ranking first in revenue. 
    Similar to the previous result, values under the metrics have small differences indicating that
    preferences for shipment providers are fairly distributed. 

*/


-- 1B. How do shipment providers perform on IN-STORE purchases according to transaction, quantity, and revenue?


WITH transactions AS(
    SELECT 
    shipmentprovider,
        COUNT(*) AS transaction_count,
        DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS tc_rank
FROM product_sales_clean
WHERE transaction_status =  'Positive Transaction'     
AND returnstatus =  'Not Returned'
AND saleschannel = 'In-Store'
GROUP BY shipmentprovider
),

quantity AS(
    SELECT
        shipmentprovider,
        SUM(quantity) AS quantity_count,
        DENSE_RANK() OVER(ORDER BY SUM(quantity) DESC) AS qc_rank  
    FROM product_sales_clean
    WHERE transaction_status =  'Positive Transaction'     
    AND returnstatus =  'Not Returned'
    AND saleschannel = 'In-Store'
    GROUP BY shipmentprovider
),

revenue AS(
    SELECT 
        shipmentprovider,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
        DENSE_RANK() OVER(ORDER BY ROUND(SUM((quantity * unitprice) * (1 - discount)),2) DESC) AS r_rank    
    FROM product_sales_clean
    WHERE transaction_status =  'Positive Transaction'     
    AND returnstatus =  'Not Returned'
    AND saleschannel = 'In-Store'
    GROUP BY shipmentprovider
)

SELECT 
    t.shipmentprovider,
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
INNER JOIN quantity q ON t.shipmentprovider = q.shipmentprovider
INNER JOIN revenue r ON t.shipmentprovider = r.shipmentprovider


/*

Query Logic:
    1. This analysis will focus on evaluating the performance of shipment providers in in-store purchases
    according to transaction, quantity, and revenue.

Result:
    
    shipmentprovider	transaction_count	tc_rank	quantity_count	qc_rank	revenue	    r_rank	overall_score	overall_rank
        FedEx	              5378	            1	    135492	        1	5116072.80	  1	        3	            1
        Royal Mail	          5290	            2	    131375	        2	4994992.26	  3	        7	            2
        DHL	                  5287	            3	    131366	        3	4982894.77	  4	        10	            3
        UPS	                  5255	            4	    130798	        4	5040590.26	  2	        10	            3

Business Insights:
    1. For overall In-Store purchases, FedEx ranked first, followed by Royal Mail, then DHL and UPS both for third place.
    Values under transaction count, quantity of units sold, and revenue are relatively close with small differences
    indicating a fair distribution of customer usage across all shipment providers.

*/


-- 2. Does order priority affect shipment provider preference

WITH choice_count AS(
    SELECT 
    orderpriority,
    shipmentprovider,
    COUNT(*) AS preference_count,
    DENSE_RANK() OVER(PARTITION BY orderpriority ORDER BY COUNT(*) DESC) AS preference_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY orderpriority, shipmentprovider
)
SELECT
    orderpriority,
    shipmentprovider,
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
    1. This analysis will evaluate potential association of order priority and 
    preference in shipment provider.

Result:
    
    orderpriority	shipmentprovider	preference_rank	preference_count
        High	        DHL	                    1	        3964
        High	        UPS	                    2	        3954
        High	        Royal Mail	            3	        3928
        High	        FedEx	                4	        3917
        Medium	        UPS	                    4	        3864
        Medium	        FedEx	                1	        4016
        Medium	        Royal Mail	            2	        3980
        Medium	        DHL	                    3	        3962
        Low	            FedEx	                1	        3969
        Low	            UPS	                    2	        3961
        Low	            Royal Mail	            3	        3908
        Low	            DHL	                    4	        3870


Business Insights:
    1. Shipment providers ranked differently across different order priorities. DHL
    ranked first in 'High' while FedEx ranked first in 'Medium' and 'Low' order priorities. 
    Preference counts under each shipment provider remained consistent with only
    small differences from each other. This suggests that there is no clear association
    between order priority and preference for shipment provider.

*/


-- 3. How do shipment providers' transaction volume, quantity handled, and revenue compare according to RETURNS?

WITH returns_rates AS(
    SELECT
    shipmentprovider,
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    (COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)), 2) AS return_rate,
    DENSE_RANK() OVER(ORDER BY ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    (COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)), 2) DESC) AS rr_rank
FROM product_sales_clean
GROUP BY shipmentprovider
),

transactions AS(
    SELECT 
    shipmentprovider,
        COUNT(*) AS transaction_count,
        DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS tc_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
AND returnstatus =  'Returned'
GROUP BY shipmentprovider
),

quantity AS(
    SELECT
        shipmentprovider,
        SUM(quantity) AS quantity_count,
        DENSE_RANK() OVER(ORDER BY SUM(quantity) DESC) AS qc_rank  
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    AND returnstatus =  'Returned'
    GROUP BY shipmentprovider
),

revenue AS(
    SELECT 
        shipmentprovider,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
        DENSE_RANK() OVER(ORDER BY ROUND(SUM((quantity * unitprice) * (1 - discount)),2) DESC) AS r_rank    
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    AND returnstatus =  'Returned'
    GROUP BY shipmentprovider
)

SELECT 
    t.shipmentprovider,
    x.return_rate,
    x.rr_rank,
    t.transaction_count,
    t.tc_rank,
    q.quantity_count,
    q.qc_rank,
    r.revenue,
    r.r_rank,
    (t.tc_rank + q.qc_rank + r.r_rank + x.rr_rank) AS overall_score,
    DENSE_RANK() OVER(
    ORDER BY (t.tc_rank + q.qc_rank + r.r_rank + x.rr_rank)
    ) AS overall_rank
FROM returns_rates x
INNER JOIN transactions t ON x.shipmentprovider = t.shipmentprovider
INNER JOIN quantity q ON x.shipmentprovider = q.shipmentprovider
INNER JOIN revenue r ON x.shipmentprovider = r.shipmentprovider


/*

Query Logic:
    1. This analysis will assess each shipment provider's transaction, product quantity, and 
    revenue according to returns.

Result:
    
    shipmentprovider	return_rate	rr_rank	transaction_count	tc_rank	quantity_count	qc_rank	revenue	    r_rank	overall_score	overall_rank
        FedEx	            9.91	  2	        1180	            1	    29627	        1	1126522.89	  1	        5	            1
        DHL	                9.99	  1	        1179	            2	    29354	        3	1088893.92	  3	        9	            2
        Royal Mail	        9.91	  2	        1171	            3	    29482	        2	1112754.65	  2	        9	            2
        UPS	                9.47	  3	        1116	            4	    27615	        4	1027424.34	  4	        15	            3


Business Insights:
    1. Based on overall returns, FedEx ranked first, followed by DHL and Royal Mail, then UPS.
    Transaction count, product quantity, and revenue across all shipment providers show relatively 
    close values. Moreover, return rates across all shipment providers show minimal percentage-point 
    differences which roughly represent one return out of every ten positive transactions. 
    Further, this indicates no major return issues attributable to shipment providers. 

*/


-- 4. How do shipment providers rank based on their OVERALL RETURN rates and PER SALES CHANNEL RETURN rates?


WITH rates AS(
SELECT
    shipmentprovider,
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)),0), 2) AS overallreturn_rate,

    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' AND saleschannel = 'Online' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'Online' THEN 1 END)),0), 2) AS onlinesalesreturn_rate,
    
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' AND saleschannel = 'In-Store' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'In-Store' THEN 1 END)),0), 2) AS instoresalesreturn_rate
FROM product_sales_clean
GROUP BY shipmentprovider
)

SELECT 
    shipmentprovider,
    overallreturn_rate,
    DENSE_RANK() OVER(ORDER BY overallreturn_rate DESC) AS overall_rank,
    onlinesalesreturn_rate,
    DENSE_RANK() OVER(ORDER BY onlinesalesreturn_rate DESC) AS online_rank,
    instoresalesreturn_rate,
    DENSE_RANK() OVER(ORDER BY instoresalesreturn_rate DESC) AS instore_rank
FROM rates
ORDER BY overall_rank;

/*

Query Logic:
    1. This analysis will evaluate the overall return rate and sales channel return rate of shipment providers.

Result:

    shipmentprovider	overallreturn_rate	overall_rank	onlinesalesreturn_rate	online_rank	instoresalesreturn_rate	instore_rank
        DHL	                9.99	            1	                9.77	            3	        10.22	                  1
        FedEx	            9.91	            2	                10.25	            1	        9.58	                  4
        Royal Mail	        9.91	            2	                9.83	            2	        9.99	                  2
        UPS	                9.47	            3	                9.29	            4	        9.66	                  3
    


Business Insights:
    1. Looking closely into hipment providers' overall return rate, online return rate, 
    and in-store return rate,  minimal percentage-point differences were observed. 
    FedEx is slightly higher among all shipment providers in online sales return rate 
    while DHL leads in in-store sales return rate. Results indicate no meaningful 
    practical difference on the return rates of shipment providers across different sales 
    channels.

*/


------------------------------------------------------------------------------------

-- 5. Which products have been sold through each warehouse location?

SELECT 
    warehouselocation,
    STRING_AGG(DISTINCT(description), ', ') AS product_list,
    COUNT(DISTINCT(description)) AS product_count
FROM product_sales_clean
GROUP BY warehouselocation
ORDER BY warehouselocation

/*

Query Logic:
    1. This analysis will determine the products sold in each warehouse location so we can 
    further assess potential association on substantial business metrics.

Result:
    
warehouselocation	product_list	                                                                                                                product_count
Amsterdam	        Backpack, Blue Pen, Desk Lamp, Headphones, Notebook, Office Chair, T-shirt, USB Cable, Wall Clock, White Mug, Wireless Mouse	11
Berlin	            Backpack, Blue Pen, Desk Lamp, Headphones, Notebook, Office Chair, T-shirt, USB Cable, Wall Clock, White Mug, Wireless Mouse	11
London	            Backpack, Blue Pen, Desk Lamp, Headphones, Notebook, Office Chair, T-shirt, USB Cable, Wall Clock, White Mug, Wireless Mouse	11
Paris	            Backpack, Blue Pen, Desk Lamp, Headphones, Notebook, Office Chair, T-shirt, USB Cable, Wall Clock, White Mug, Wireless Mouse	11
Rome	            Backpack, Blue Pen, Desk Lamp, Headphones, Notebook, Office Chair, T-shirt, USB Cable, Wall Clock, White Mug, Wireless Mouse	11
Unspecified	        Backpack, Blue Pen, Desk Lamp, Headphones, Notebook, Office Chair, T-shirt, USB Cable, Wall Clock, White Mug, Wireless Mouse	11


Business Insights:

    1. The warehouse locations are Amsterdam, Berlin, London, paris, Rome, and an Unspecified
    location. All warehouse locations carry the same 11 products, indicating a standardized 
    product assrtment across warehouses. This suggests that inventory is consistently 
    distributed, allowing each warehouse to fulfill order for the complete product catalog.
    Further analysis of transaction volume, product quantity, and revenue by warehouse is needed
    to determine whether customer demand differs across warehouse locations.

*/

-- 6. Which top three products are most frequently sold from each warehouse?

WITH warehousestocks AS (
    SELECT 
        warehouselocation,
        description,
        COUNT(description) product_quantity,
        DENSE_RANK() OVER(PARTITION By warehouselocation ORDER BY COUNT(description) DESC) AS product_rank
    FROM product_sales_clean
    WHERE transaction_status =  'Positive Transaction'     
    GROUP BY warehouselocation, description
)

SELECT 
    warehouselocation,
    description,
    product_quantity,
    product_rank
FROM warehousestocks
WHERE product_rank <= 3

/*

Query Logic:
    1. This analysis will determine top three most frequently sold products 
    in each warehouse and ranks them according to the number of positive sales 
    transactions.

Result:
    
warehouselocation	description	    product_quantity	product_rank
Amsterdam	        Backpack	        920	                1
Amsterdam	        USB Cable	        907	                2
Amsterdam	        Blue Pen	        874	                3
Berlin	            Wall Clock	        886	                1
Berlin	            Headphones	        865	                2
Berlin	            T-shirt	            856	                3
London	            Office Chair	    883	                1
London	            Blue Pen	        867	                2
London	            Desk Lamp	        862	                3
Paris	            Desk Lamp	        860	                1
Paris	            White Mug	        854	                2
Paris	            USB Cable	        851	                3
Rome	            Wall Clock	        886	                1
Rome	            Desk Lamp	        874	                2
Rome	            White Mug	        867	                3
Unspecified	        Office Chair	    96	                1
Unspecified	        T-shirt	            96	                1
Unspecified	        Headphones	        96	                1
Unspecified	        Wireless Mouse	    95	                2
Unspecified	        White Mug	        93	                3


Business Insights:
    1. Top three most frequently sold products across all warehouse locations are diversified.
   Noticeably, Wall Clock and Office Chair ranked first on two locations. Top product 
   quantity count on each location showed small differences suggesting no clear dominant 
   product per warehouse location. Moreover, there is also no single product line dominating
   across warehouse locations.

*/


-- 7. How do warehouse locations perform according to their transaction volume, quantity handled, and revenue?

WITH transactions AS(
    SELECT 
        warehouselocation,
        COUNT(*) AS transaction_count,
        DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS tc_rank
FROM product_sales_clean
WHERE transaction_status =  'Positive Transaction'     
AND returnstatus =  'Not Returned' 
GROUP BY warehouselocation
),
quantity AS(
    SELECT
        warehouselocation,
        SUM(quantity) AS quantity_count,
        DENSE_RANK() OVER(ORDER BY SUM(quantity) DESC) AS qc_rank  
    FROM product_sales_clean
    WHERE transaction_status =  'Positive Transaction'     
    AND returnstatus =  'Not Returned' 
    GROUP BY warehouselocation
),
revenue AS(
    SELECT 
        warehouselocation,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
        DENSE_RANK() OVER(ORDER BY ROUND(SUM((quantity * unitprice) * (1 - discount)),2) DESC) AS r_rank    
    FROM product_sales_clean
    WHERE transaction_status =  'Positive Transaction'     
    AND returnstatus =  'Not Returned' 
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
INNER JOIN quantity q ON t.warehouselocation = q.warehouselocation
INNER JOIN revenue r ON t.warehouselocation = r.warehouselocation

/*

Query Logic:
    1. This analysis will show how each warehouse location perform according to their transaction volume, 
    quantity handled, and revenue.

Result:
    
warehouselocation	transaction_count	tc_rank	quantity_count	qc_rank	revenue	    r_rank	overall_score	overall_rank
Amsterdam	        8530	              1	        210275	        1	7982280.33	  1	        3	            1
London	            8343	              2	        208343	        2	7938173.64	  2	        6	            2
Rome	            8334	              3	        208322	        3	7900466.81	  3	        9	            3
Berlin	            8290	              4	        206593	        4	7860375.52	  4	        12	            4
Paris	            8248	              5	        205791	        5	7788544.43	  5	        15	            5
Unspecified	        902	                  6	        21890	        6	808257.93	  6	        18	            6


Business Insights:

    1. Values for transaction count, product quantity, and revenue are relatively close across the five
    specified warehouse locations, while the Unspecified location records substantially lower values. Among 
    the specified warehouses, revenues range from approximately 7.79M to 7.98M, quantities handled from 
    205K to 210K units, and transaction counts from 8.2K to 8.5K. Although Amsterdam ranked first across
    all three performance metrics, the differences between the major warehouse locations are relatively
    small, suggesting that operational workload and sales performance are fairly balanced, with no 
    warehouse showing a clear operational dominance. 

*/


-- 8. How do warehouse locations' transaction volume, quantity handled, and revenue compare according to RETURNS?

WITH transactions AS(
SELECT 
    warehouselocation,
        COUNT(*) AS transaction_count,
        DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS tc_rank
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
AND returnstatus =  'Returned'
GROUP BY warehouselocation
),

quantity AS(
    SELECT
        warehouselocation,
        SUM(quantity) AS quantity_count,
        DENSE_RANK() OVER(ORDER BY SUM(quantity) DESC) AS qc_rank  
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    AND returnstatus =  'Returned'
    GROUP BY warehouselocation
),

revenue AS(
    SELECT 
        warehouselocation,
        ROUND(SUM((quantity * unitprice) * (1 - discount)),2) AS revenue,
        DENSE_RANK() OVER(ORDER BY ROUND(SUM((quantity * unitprice) * (1 - discount)),2) DESC) AS r_rank    
    FROM product_sales_clean
    WHERE transaction_status = 'Positive Transaction'
    AND returnstatus =  'Returned'
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
INNER JOIN quantity q ON t.warehouselocation= q.warehouselocation
INNER JOIN revenue r ON t.warehouselocation = r.warehouselocation

/*

Query Logic:
    1. This analysis will look into warehouse locations' transaction volume, quantity, and revenue based on 
    returns.

Result:
    
warehouselocation	transaction_count	tc_rank	quantity_count	qc_rank	revenue	    r_rank	overall_score	overall_rank
Berlin	                920	              3	        23150	        1	882182.53	  1	        5	            1
Amsterdam	            928	              1	        23135	        2	859819.98	  3	        6	            2
Paris	                925	              2	        23102	        3	860287.94	  2	        7	            3
Rome	                892	              4	        21853	        5	827158.26	  4	        13	            4
London	                887	              5	        22285	        4	819573.48	  5	        14	            5
Unspecified	            94	              6	        2553	        6	106573.60	  6	        18	            6


Business Insights:

    1. Excluding the Unspecified location, transaction counts, product quantities, and revenues associated with 
    returned orders remain relatively close across all warehouse locations. Transaction counts range from 887
    to 928, quantites from approximately 22K to 23K units, and revenues from 819K to 882K. Although Berlin ranked
    first overall because it recorded the highest quantity and revenue associated with returned purchases, the 
    differences across the specified warehouse locations are relatively small. These findings suggest that 
    returned transactions are fairly distributed among warehouse locations, with no warehouse showing a 
    substantially higher concentration of returns than the others.

*/


-- 9. How do warehouse locations rank based on their OVERALL RETURN rates and PER SALES CHANNEL RETURN rates?

WITH rates AS(
SELECT
    warehouselocation,
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)),0), 2) AS overallreturn_rate,

    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' AND saleschannel = 'Online' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'Online' THEN 1 END)),0), 2) AS onlinesalesreturn_rate,
    
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' AND saleschannel = 'In-Store' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'In-Store' THEN 1 END)),0), 2) AS instoresalesreturn_rate
FROM product_sales_clean
GROUP BY warehouselocation
)

SELECT 
    warehouselocation,
    overallreturn_rate,
    DENSE_RANK() OVER(ORDER BY overallreturn_rate DESC) AS overall_rank,
    onlinesalesreturn_rate,
    DENSE_RANK() OVER(ORDER BY onlinesalesreturn_rate DESC) AS online_rank,
    instoresalesreturn_rate,
    DENSE_RANK() OVER(ORDER BY instoresalesreturn_rate DESC) AS instore_rank
FROM rates
ORDER BY overall_rank


/*

Query Logic:
    1. This analysis will evaluate the overall return rate and sales channel return rate of warehouse locations.

Result:
    
warehouselocation	overallreturn_rate	overall_rank	onlinesalesreturn_rate	online_rank	instoresalesreturn_rate	instore_rank
Paris	                10.08	            1	                9.39	            5	            10.76	            1
Berlin	                9.99	            2	                10.13	            2	            9.85	            2
Amsterdam	            9.81	            3	                10.15	            1	            9.47	            5
Rome	                9.67	            4	                9.86	            3	            9.47	            5
London	                9.61	            5	                9.45	            4	            9.77	            4
Unspecified	            9.44	            6	                9.05	            6	            9.82	            3


Business Insights:

    1. Ranking of warehouse locations vary across overall return rate and sales-channel-specific
    return rates. Paris ranked first in both overall return rate (10.08%) and In-Store return
    rate (10.76%), while Amsterdam ranked first in Online return rate (10.15%). Despite these ranking 
    differences, return rates across all warehouse locations remain within a relatively narrow range
    of 9.05% to 10.76%. This indicates that no warehouse location exhibits a substantially higher
    return rate than the others, suggesting no strong evidence that warehouse location is a major
    driver of product returns.

*/


-- 10. How do warehouse location preferences differ across customers' countries of origin?

WITH choice_count AS(
    SELECT 
    country,
    warehouselocation,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END) AS preference_count,
    DENSE_RANK() OVER(PARTITION BY country ORDER BY COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END) DESC) 
        AS preference_rank
FROM product_sales_clean
GROUP BY warehouselocation, country
)
SELECT
    country,
    warehouselocation,
    preference_rank,
    preference_count
FROM choice_count
ORDER BY country

/*

Query Logic:
    1. This analysis will evaluate whether the customer's country of origin has an 
    association on warehouse location preferences.

Result:

Note: The information pasted on this section is just partial piece of the overall query result.


country	    warehouselocation	preference_rank	  preference_count
Australia	Rome	                    1	             788
Australia	Berlin	                    2	             774
Australia	Paris	                    3	             762
Australia	London	                    4	             749
Australia	Amsterdam	                5	             745
Australia	Unspecified	                6	              76


Business Insights:

     1. Warehouse location preferences vary across countries, with no single warehouse
     consistently ranking first across all customer origins. Preference count within
     each country are generally close among the specified warehouse locations, while 
     the Unspecified location consistently records the fewest transactions. These 
     findings suggest that customers' country of origin shows no strong association
     with warehouse location preference.  

*/



-- ====================================================================
--                         SECTION KEY FINDINGS
-- ====================================================================

/*


     1. Shipment provider performance is broadly distributed across transaction volume,
product quantity handled, revenue, and customer preferences. Although FedEx ranked
first in overall operational performance while UPS led Online purchases, differences
among shipment providers remained relatively small. Return rates also stayed within
a narrow range, suggesting no shipment provider demonstrates a clear operational
advantage or substantially higher return issue.

2. Warehouse operations appear to be consistently balanced. All specified warehouse
locations maintain the same product assortment, while transaction volume, quantity
handled, revenue, and returned transactions remain closely distributed across the
major warehouses. Although Amsterdam ranked first in overall operational performance,
performance differences were minimal, indicating no warehouse exhibits clear operational
dominance.

3. Customer preferences for both shipment providers and warehouse locations vary across
countries and order priorities. However, preference counts remain relatively consistent
across the available options, suggesting that neither customer origin nor order priority
shows a strong association with shipment provider or warehouse location selection.

*/

-- =====================================================================
--                  SQL PROJECT 1: PRODUCT SALES ANALYSIS
--                     SECTION 8: RETURNS ANALYSIS
-- =====================================================================

-- 1. What is the overall return rate?

SELECT 
    COUNT(*) AS overalltransaction_count,
    COUNT(CASE WHEN returnstatus = 'Returned' THEN 1 END) AS overallreturn_count,
    CONCAT(ROUND((COUNT(CASE WHEN returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF(COUNT(*),0 ),2), '%') AS return_rate
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'


/*

Query Logic:
    1. This query will determine the return count and total return rate of the business.

Result:
    
    overalltransaction_count    overallreturn_count	return_rate
            47293	                    4646	      9.82%

Business Insights:
    1. Return rate is 9.82% of 47,293 positive transactions which is 
    roughly one out of every 10 positive transactions.

*/


-- 2. How do categories rank on their return rates?

SELECT 
    category,
    COUNT(*) AS transactions,
    CONCAT(ROUND((COUNT(CASE WHEN returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF(COUNT(*),0 ),2),'%') AS return_rate
FROM product_sales_clean
WHERE transaction_status = 'Positive Transaction'
GROUP BY category
ORDER BY COUNT(CASE WHEN returnstatus = 'Returned' THEN 1 END) * 100.0
/
NULLIF(COUNT(*),0) DESC;


/*

Query Logic:
    1. This analysis will evaluate the rankings of categories based on 
    their return rates.

Result:
    
    category	transactions	return_rate
    Stationery	    8494	      10.29%
    Apparel	        4268	      10.05%
    Electronics	    12857	      9.75%
    Furniture	    13001	      9.66%
    Accessories	    8673	      9.60%


Business Insights:
    1. Stationery ranked first in highest return rate with 10.29%
    while Accessories ranked the lowest with 9.60% return rate. 
    While return rates across all categories are roughly equivalent 
    to one out of every positive transaction further analysis is still
    important to determine factors associated with product returns.

*/


-- 3. Which products have the highest return rates?

SELECT 
    description,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END) AS positive_transactions,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END) AS returns_count,
    CONCAT(ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)),0),2),'%') AS return_rate
FROM product_sales_clean
GROUP BY description
ORDER BY COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END)*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)),0) DESC;


/*

Query Logic:
    1. This analysis will determine each products' return rate and ranks them
    from highest to lowest.

Result:
    
    description	 positive_transactions	returns_count	return_rate
    Notebook	        4230	            442	          10.45%
    Blue Pen	        4264	            432	          10.13%
    Wall Clock	        4362	            440	          10.09%
    T-shirt	            4268	            429	          10.05%
    USB Cable	        4359	            437	          10.03%
    Wireless Mouse	    4216	            411	          9.75%
    Backpack	        4355	            423	          9.71%
    Desk Lamp	        4338	            416	          9.59%
    White Mug	        4318	            410	          9.50%
    Headphones	        4282	            406	          9.48%
    Office Chair	    4301	            400	          9.30%


Business Insights:
    1. Notebook has the highest return rate among all the products, at 10.45% of its positive 
    transactions. Return rates range from 9.30% to 10.45% across all products, with no major 
    differences in return rates.

*/


-- 4. Are online purchases returned more often than in-store purchases?

SELECT
    saleschannel,
    COUNT(CASE
        WHEN transaction_status = 'Positive Transaction'
        THEN 1
    END) AS positive_transactions,

    COUNT(CASE
        WHEN transaction_status = 'Positive Transaction'
        AND returnstatus = 'Returned'
        THEN 1
    END) AS returned_orders,

    ROUND(
        COUNT(CASE
            WHEN transaction_status = 'Positive Transaction'
            AND returnstatus = 'Returned'
            THEN 1
        END) * 100.0
        /
        NULLIF(
            COUNT(CASE
                WHEN transaction_status = 'Positive Transaction'
                THEN 1
            END),
        0),
    2) AS return_rate
FROM product_sales_clean
GROUP BY saleschannel
ORDER BY return_rate DESC;


/*

Query Logic:
    1. This analysis will assess potential association between sales channel and 
    returns.

Result:
    
    saleschannel	positive_transactions	returned_orders	    return_rate
      In-Store	            23531	            2321	            9.86
      Online	            23762	            2325	            9.78

Business Insights:
    1. Return rates across In-Store and Online are relatively close, both having
    roughly one out of every ten positive transactions. In-Store sales channel
    is only 0.08 percentage points higher than Online sales channel in terms of return rates. 
    Results suggest that there is no clear association between return rates and sales channel.

*/


-- 5. What is the return rate per category for online purchases?

SELECT
    category,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'Online' THEN 1 END) AS onlinetransactioncount,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'Online' AND returnstatus = 'Returned' THEN 1 END) AS returns_count,
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'Online' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'Online' THEN 1 END)),0),2) AS return_rate
FROM product_sales_clean
GROUP BY category
ORDER BY return_rate


/*

Query Logic:
    1. This analysis will evaluate return rates per category specifically in
    online purchases.

Result:
    
    category	onlinetransactioncount	returns_count	return_rate
    Electronics	        6431	             606	         9.42
    Apparel	            2120	             207	         9.76
    Furniture	        6569	             642	         9.77
    Accessories	        4318	             432	         10.00
    Stationery	        4324	             438	         10.13


Business Insights:
    1. Similar to the previous result, Stationery ranked first on highest return rate
    per category in online purchases having 10.13%, Accessories with 10%, Furniture with 
    9.77%, Apparel with 9.76%, and Electronics with 9.42%. Return rates across all categories 
    show minimal differences, suggesting a fairly even distribution of customer returns 
    across categories. Moreover, no category shows evidence of substantially higher return 
    rates than the other but the results in the analysis still require monitoring.  

*/


-- 6. What is the return rate per category for in-store purchases?

SELECT
    category,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'In-Store' THEN 1 END) AS instoretransactioncount,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'In-Store' AND returnstatus = 'Returned' THEN 1 END) AS returns_count,
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'In-Store' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND saleschannel = 'In-Store' THEN 1 END)),0),2) AS return_rate
FROM product_sales_clean
GROUP BY category
ORDER BY return_rate DESC

/*

Query Logic:
    1. This analysis will evaluate return rates per category specifically in
    in-store purchases.

Result:
    
    category	instoretransactioncount	returns_count	return_rate
    Stationery	        4170	            436	          10.46
    Apparel	            2148	            222	          10.34
    Electronics	        6426	            648	          10.08
    Furniture	        6432	            614	          9.55
    Accessories	        4355	            401	          9.21


Business Insights:
    1. Similar to online purchases, Stationery still ranked first in return rate 
    in In-Store. Values of return rates across categories similarly displayed minimal 
    differences and remained at roughly ten percent. Results in In-Store purchases
    suggest that sales channel has minimal association with category return rates.

*/


-- 7. Which countries have the highest return rates?

SELECT
    country,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END) AS transactioncount,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END) AS returns_count,
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)),0),2) AS return_rate
FROM product_sales_clean
GROUP BY country
ORDER BY return_rate DESC

/*

Query Logic:
    1. This analysis will identify countries' return rate and ranked them from 
    highest to lowest.

Result:
    
    country	    transactioncount	returns_count	return_rate
    Australia	    3894	            410	          10.53
    Germany	        3972	            404	          10.17
    Sweden	        3994	            399	          9.99
    Belgium	        3963	            396	          9.99
    Italy	        3845	            381	          9.91
    France	        4021	            396	          9.85
    United Kingdom	3973	            391	          9.84
    Portugal	    3959	            387	          9.78
    United States	3880	            379	          9.77
    Netherlands	    3957	            376	          9.50
    Norway	        3938	            371	          9.42
    Spain	        3897	            356	          9.14

Business Insights:
    1. Across all countries, return rates range from 9.14% to 10.53%. This is approximately 
    equivalent to one return for every ten positive transactions in each country. Australia 
    leads in the ranking with 10.53% return rate, followed closely by Germany and Sweden. 
    Return rates are consistent with previous findings, showing no major percentage-point 
    differences across countries.

*/


-- 8. Does discount level influence return rate?

WITH discount_groups AS(
    SELECT
        CASE 
            WHEN discount = 0 THEN 'No Discount'
            WHEN discount <= 0.10 THEN 'Low Discount'
            WHEN discount <= 0.20 THEN 'Medium Discount'
            ELSE 'High Discount'
        END AS discount_level,
        transaction_status,
        returnstatus
    FROM product_sales_clean

)
SELECT 
    discount_level,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END) AS transactions,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END) AS returns,
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)),0),2) AS return_rate   
FROM discount_groups
GROUP BY discount_level
ORDER BY return_rate DESC


/*

Query Logic:
    1. This analysis will assess whether there is a potential association 
    between discount levels and return rates.

Result:
    
    discount_level	transactions	returns	return_rate
    No Discount	        486	          49	  10.08
    High Discount	    27968	      2755	  9.85
    Medium Discount	    9459	      932	  9.85
    Low Discount	    9380	      910	  9.70


Business Insights:
    1. At all discount levels, return rates remain at approximately 10%. 'No Discount' 
    has the highest return rate, exceeding both 'High Discount' and 'Medium Discount' 
    by only 0.23 percentage points. Results indicate that discount levels alone are 
    unlikely to be associated with return rates.

*/


-- 9. Does order priority influence return rates?

SELECT 
    orderpriority,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END) AS transactions,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END) AS returns,
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)),0),2) AS return_rate   
FROM product_sales_clean
GROUP BY orderpriority
ORDER BY return_rate DESC


/*

Query Logic:
    1. This analysis will evaluate whether order priority has potential 
    association with return rates.

Result:
    
    orderpriority	transactions	returns	    return_rate
        High	        15763	      1563	       9.92
        Medium	        15822	      1551	       9.80
        Low	            15708	      1532	       9.75


Business Insights:
    1. Return rates across order priorities are noticeably 
    close with minimal percentage points difference. 'High'
    order priority ranked first, followed by 'Medium' then 
    'Low' order priority with return rates ranging from 9.75% 
    to 9.92%. This suggests no clear association between order
    priorities and return rates.

*/


-- 10. Which payment methods are associated with the highest return rates?

SELECT 
    paymentmethod,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END) AS transactions,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END) AS returns,
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)),0),2) AS return_rate   
FROM product_sales_clean
GROUP BY paymentmethod
ORDER BY return_rate DESC


/*

Query Logic:
    1. This analysis will support in determining payment methods
    likely to be associated with high return rates.

Result:
    
    paymentmethod	transactions	returns	    return_rate
    Bank Transfer	    15933	      1593	      10.00
    Paypall	            15639	      1531	      9.79
    Credit Card	        15721	      1522	      9.68


Business Insights:
    1. Similar to the results from previous queries, return rates
    across payment methods are relatively close with just a 
    small percentage-point difference. Return rates range from 9.68%
    to 10%, with Bank Transfer having the highest and Credit Card 
    having the lowest. Results show that payment method is unlikely to be
    associated with return rates. 

*/


-- 11. Which shipment providers have the highest return rates?

SELECT 
    shipmentprovider,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END) AS transactions,
    COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END) AS returns,
    ROUND((COUNT(CASE WHEN transaction_status = 'Positive Transaction' AND returnstatus = 'Returned' THEN 1 END))*100.00
    /
    NULLIF((COUNT(CASE WHEN transaction_status = 'Positive Transaction' THEN 1 END)),0),2) AS return_rate   
FROM product_sales_clean
GROUP BY shipmentprovider
ORDER BY return_rate DESC

/*

Query Logic:
    1. This analysis will determine all the shipment providers
    and show their corresponding return rates which will be further 
    assessed for potential association.

Result:
    
    shipmentprovider	transactions	returns	  return_rate
        DHL	                11796	      1179	    9.99
        FedEx	            11902	      1180	    9.91
        Royal Mail	        11816	      1171	    9.91
        UPS	                11779	      1116	    9.47


Business Insights:
    1. Return rates across all shipment providers remain within 
    a narrow range of 9.47% to 9.99%. DHL leads the ranking with
    9.99%, followed by FedEx and Royal Mail both at 9.91%, then
    UPS with 9.47%. Minimal percentage-point differences indicate 
    no clear relationship between shipment providers and return
    rates.

*/


-- 12. Do returned purchases always correspond to negative transactions?

WITH rate AS(
    SELECT
        transaction_status,
        returnstatus,
        COUNT(*) AS transactions
    FROM product_sales_clean
    GROUP BY transaction_status, returnstatus
)
SELECT 
    transaction_status,
    returnstatus,
    transactions,
    ROUND((transactions)*100.00
    /
    NULLIF((SUM(transactions) OVER(PARTITION BY transaction_status)),0),2) AS rate
FROM rate
ORDER BY 
    CASE transaction_status
        WHEN 'Positive Transaction' THEN 1
        ELSE 2
    END ASC, returnstatus


/*

Query Logic:
    1. This analysis will check whether returned purchases solely
    belongs to negative transactions and to further have a glimpse
    on the distribution of data across positive and negative transactions
    with their return status, transaction count, and returns.

    Note that throughout the analysis positive transaction is used as the 
    business baseline to focus on successful transactions and to clearly 
    have a picture on the business's performance. A separate section was 
    dedicated for the analysis of negative transaction.


Result:
    
    transaction_status	    returnstatus	transactions	rate
    Positive Transaction	Not Returned	    42647	    90.18
    Positive Transaction	Returned	        4646	    9.82
    Negative Transaction	Not Returned	    2241	    90.04
    Negative Transaction	Returned	        248	        9.96

Business Insights:
    1. Results show that returned purchases do not only belong exclusively to 
    negative transactions. They exist under both transaction statuses. 
    Positive transactions  have returned cases with a rate of 9.82%, which is 
    only 0.14 percentage points lower than negative transactions (9.96%). The return 
    rate of positive transactions is consistent with previous query results having 
    return rates ranging from 9% to 10% which was all filtered according to positive 
    transactions. 

*/

UPDATE product_sales_clean
SET paymentmethod = 'PayPal'
WHERE paymentmethod = 'Paypall';



-- ====================================================================
--                         SECTION KEY FINDINGS
-- ====================================================================

/*

1. Overall return rates remain consistently close to 10%, equivalent to approximately
one return for every ten positive transactions. Across products, categories, countries,
sales channels, discount levels, order priorities, payment methods, and shipment
providers, return rates exhibit only small percentage-point differences, indicating
that customer returns are broadly distributed rather than concentrated within a
specific business segment.

2. Although Stationery, Notebook, Australia, Bank Transfer, DHL, High-priority orders,
and No Discount transactions ranked first within their respective analyses, their
return rates exceed the lowest-ranked groups by only small margins. These findings
suggest that the ranking differences are not substantial enough to indicate a clear
operational or customer-related return issue.

3. Returned purchases occur under both positive and negative transaction statuses.
Positive transactions recorded a return rate of 9.82%, while negative transactions
recorded 9.96%, differing by only 0.14 percentage points. This further supports the
overall finding that returns remain consistently distributed across transaction types
and show no meaningful association with any single business factor evaluated.
*/
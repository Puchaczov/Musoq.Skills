let path: string = r'orders.csv'
SELECT c.Customer AS Customer, Count(*) AS Orders, Sum(c.Amount::int) AS Total
FROM separatedvalues.comma($path, true, 0) c
GROUP BY c.Customer ORDER BY c.Customer

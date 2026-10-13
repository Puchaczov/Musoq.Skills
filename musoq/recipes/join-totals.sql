SELECT c.Name AS Customer, Count(*) AS Orders, Sum(o.Amount) AS Total
FROM values {
  (CustomerId: 10, Amount: 12), (CustomerId: 10, Amount: 18), (CustomerId: 20, Amount: 7)
} o
INNER JOIN values { (CustomerId: 10, Name: 'Ada'), (CustomerId: 20, Name: 'Bob') } c
  ON o.CustomerId = c.CustomerId
GROUP BY c.Name ORDER BY Customer

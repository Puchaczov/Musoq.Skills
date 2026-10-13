SELECT s.Id AS Id, Count(*) AS Copies
FROM values { (Id: 10), (Id: 10), (Id: 20) } s
GROUP BY s.Id HAVING Count(*) > 1 ORDER BY s.Id

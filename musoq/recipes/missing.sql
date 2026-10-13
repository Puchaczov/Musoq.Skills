SELECT a.Id AS MissingId
FROM values { (Id: 1), (Id: 2), (Id: 3) } a
LEFT OUTER JOIN values { (Id: 1), (Id: 3) } b ON a.Id = b.Id
WHERE b.Id IS NULL ORDER BY a.Id

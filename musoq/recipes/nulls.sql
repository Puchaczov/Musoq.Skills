SELECT s.Id AS Id, CASE WHEN s.Value IS NULL THEN 'missing' ELSE s.Value END AS Label
FROM values { (Id: 1, Value: null), (Id: 2, Value: 'ready') } s ORDER BY s.Id

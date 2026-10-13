WITH previous AS (
 SELECT p.Id AS Id, p.Value AS Value FROM values { (Id: 1, Value: 'old'), (Id: 2, Value: 'gone') } p
), current AS (
 SELECT c.Id AS Id, c.Value AS Value FROM values { (Id: 1, Value: 'new'), (Id: 3, Value: 'fresh') } c
), changes AS (
 SELECT a.Id AS Id,
        CASE WHEN b.Id IS NULL THEN 'removed'
             WHEN a.Value IS DISTINCT FROM b.Value THEN 'changed' ELSE 'same' END AS Change
 FROM previous a LEFT OUTER JOIN current b ON a.Id = b.Id
 UNION ALL
 SELECT b.Id AS Id, 'added' AS Change
 FROM current b LEFT OUTER JOIN previous a ON a.Id = b.Id WHERE a.Id IS NULL
)
SELECT Id, Change FROM changes ORDER BY Id

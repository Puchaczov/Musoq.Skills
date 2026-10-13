param(root: string = '.')
WITH patterns AS (
 SELECT p.Id AS Id, p.Pattern AS Pattern
 FROM values { (Id: 'todo', Pattern: 'TODO'), (Id: 'fixme', Pattern: 'FIXME') } p
)
SELECT m.PatternId AS Pattern, Count(*) AS Hits
FROM search.many($root, patterns: patterns, options: (scope: (include: array { 'src/*.cs' }))) m
GROUP BY m.PatternId ORDER BY m.PatternId

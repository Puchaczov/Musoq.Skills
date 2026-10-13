param(root: string = '.')
WITH hits AS (
 SELECT m.Path AS Path, m.PatternId AS Pattern
 FROM search.many($root, patterns: array {
  (id: 'todo', pattern: 'TODO'), (id: 'fixme', pattern: 'FIXME')
 }, options: (scope: (include: array { 'src/*.cs' }))) m
), priority AS (
 SELECT h.Path AS Path, Count(*) AS Hits FROM hits h GROUP BY h.Path HAVING Count(*) >= 2
)
SELECT p.Path AS Path, p.Hits AS Hits, s.LineNumber AS Line, s.LineText AS Text
FROM priority p INNER JOIN search.lines($root, 'FIXME', options: (scope: (include: array { 'src/*.cs' }))) s
 ON p.Path = s.Path
ORDER BY p.Path, s.LineNumber

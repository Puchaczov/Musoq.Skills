param(root: string = '.')
SELECT m.PatternId AS Pattern, Count(*) AS Hits
FROM search.many($root, patterns: array {
  (id: 'todo', pattern: 'TODO'), (id: 'fixme', pattern: 'FIXME')
}, options: (scope: (include: array { 'src/*.cs' }))) m
GROUP BY m.PatternId ORDER BY m.PatternId

-- Question: which files contain both concepts, regardless of repeated occurrences?
-- Edit root, the two labels/patterns and scope. Lexical co-occurrence is not a dependency.
param(root: string = '.')
WITH topics AS (
 SELECT m.Path AS Path, m.PatternId AS Topic
 FROM search.many($root, patterns: array {
  (id: 'old', pattern: 'OldApi('), (id: 'new', pattern: 'NewApi(')
 }, options: (scope: (include: array { 'src/*.cs', 'src/**/*.cs' },
  exclude: array { '**/obj/**', '**/bin/**', 'src/generated/**' }))) m
 GROUP BY m.Path, m.PatternId
)
SELECT t.Path AS Path, Count(*) AS Topics FROM topics t
GROUP BY t.Path HAVING Count(*) = 2 ORDER BY t.Path

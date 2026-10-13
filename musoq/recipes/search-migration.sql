-- Question: which files have old-API candidates without replacement candidates?
-- Edit root, patterns and scope. Comments/strings remain candidates; inspect bodies.
param(root: string = '.')
WITH topics AS (
 SELECT m.Path AS Path, m.PatternId AS Topic
 FROM search.many($root, patterns: array {
  (id: 'old', pattern: 'OldApi('), (id: 'new', pattern: 'NewApi(')
 }, options: (scope: (include: array { 'src/*.cs', 'src/**/*.cs' },
  exclude: array { '**/obj/**', '**/bin/**', 'src/generated/**' }))) m
 GROUP BY m.Path, m.PatternId
)
SELECT old.Path AS Path FROM topics old LEFT OUTER JOIN topics replacement
 ON old.Path = replacement.Path AND replacement.Topic = 'new'
WHERE old.Topic = 'old' AND replacement.Path IS NULL ORDER BY old.Path

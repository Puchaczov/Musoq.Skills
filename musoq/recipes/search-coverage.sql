-- Question: where do declaration, call, test and configuration candidates occur?
-- Edit root, labels/patterns and scope. Counts are occurrences, not resolved symbols.
param(root: string = '.')
SELECT m.PatternId AS Topic, m.Path AS Path, Count(*) AS Occurrences
FROM search.many($root, patterns: array {
 (id: 'declaration', pattern: 'class Worker'),
 (id: 'call', pattern: 'RunJob('),
 (id: 'test', pattern: 'RunJob_Should'),
 (id: 'configuration', pattern: 'JobsEnabled')
}, options: (scope: (include: array { 'src/*.cs', 'src/**/*.cs', 'tests/*.cs', 'tests/**/*.cs', 'config/*.json' },
 exclude: array { '**/obj/**', '**/bin/**', 'src/generated/**' }))) m
GROUP BY m.PatternId, m.Path ORDER BY m.PatternId, m.Path

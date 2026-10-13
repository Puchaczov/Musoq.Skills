-- Question: what are the first two evidence locations per topic?
-- Edit labels/patterns, scope and QUALIFY cap. Ordering is deterministic, not relevance scoring.
param(root: string = '.')
SELECT m.PatternId AS Topic, m.Path AS Path, m.LineNumber AS Line,
 m.MatchText AS Match, RowNumber() OVER (
  PARTITION BY m.PatternId ORDER BY m.Path, m.LineNumber, m.MatchIndex
 ) AS Position
FROM search.many($root, patterns: array {
 (id: 'old', pattern: 'OldApi('), (id: 'new', pattern: 'NewApi(')
}, options: (scope: (include: array { 'src/*.cs', 'src/**/*.cs' },
 exclude: array { '**/obj/**', '**/bin/**', 'src/generated/**' }))) m
QUALIFY Position <= 2 ORDER BY Topic, Position

-- Question: which same-file LEFT/RIGHT pairs fall outside the permitted proximity?
-- Edit root, patterns, scope and bounds. Non-null Search coordinates define the relationship.
-- RIGHT is permitted within the following two lines, or after LEFT on the same line
-- with at most 32 UTF-16 units between them. NOT filters pairs; it does not prove absence.
-- TAKE is a preview cap. Dense pair joins can be costly; narrow the input first.
param(root: string = '.')
SELECT l.Path AS Path, l.LineNumber AS LeftLine, r.LineNumber AS RightLine,
 l.Utf16Column AS LeftColumn, r.Utf16Column AS RightColumn
FROM search.matches($root, 'LEFT', options: (scope: (include: array { 'proximity/*.txt' }))) l
INNER JOIN search.matches($root, 'RIGHT', options: (scope: (include: array { 'proximity/*.txt' }))) r ON l.Path = r.Path
WHERE NOT (
 r.LineNumber >= l.LineNumber AND r.LineNumber <= l.LineNumber + 2
 AND (r.LineNumber > l.LineNumber OR (
  r.Utf16Column >= l.Utf16Column + l.Utf16Length
  AND r.Utf16Column <= l.Utf16Column + l.Utf16Length + 32
 ))
)
ORDER BY l.Path, l.LineNumber, l.Utf16Column, r.LineNumber, r.Utf16Column TAKE 100

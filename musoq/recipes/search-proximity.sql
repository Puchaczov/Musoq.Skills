-- Question: which LEFT/RIGHT candidates share a file and occur within two lines?
-- Edit root, patterns, scope and window. Take caps output only; dense joins can be costly.
-- Same-line RIGHT must follow LEFT within 32 UTF-16 units. This is lexical proximity.
-- Two source references do not promise two physical scans or bounded join work.
param(root: string = '.')
SELECT l.Path AS Path, l.LineNumber AS LeftLine, r.LineNumber AS RightLine,
 l.Utf16Column AS LeftColumn, r.Utf16Column AS RightColumn
FROM search.matches($root, 'LEFT', options: (scope: (include: array { 'proximity/*.txt' }))) l
INNER JOIN search.matches($root, 'RIGHT', options: (scope: (include: array { 'proximity/*.txt' }))) r ON l.Path = r.Path
WHERE r.LineNumber >= l.LineNumber AND r.LineNumber <= l.LineNumber + 2
 AND (r.LineNumber > l.LineNumber OR (
  r.Utf16Column >= l.Utf16Column + l.Utf16Length
  AND r.Utf16Column <= l.Utf16Column + l.Utf16Length + 32
 ))
ORDER BY l.Path, l.LineNumber, l.Utf16Column, r.LineNumber, r.Utf16Column TAKE 100

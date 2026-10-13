param(root: string = '.')
SELECT m.Path AS Path, c.LineNumber AS Line, c.LineText AS Text
FROM search.matches($root, 'FIXME', options: (
  context: (beforeLines: 1, afterLines: 1),
  scope: (include: array { 'src/Alpha.cs' })
)) m CROSS APPLY m.Context c
ORDER BY c.LineNumber

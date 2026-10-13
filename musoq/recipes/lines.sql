param(root: string = '.')
SELECT s.Path AS Path, s.LineNumber AS Line, s.LineText AS Text
FROM search.lines($root, 'FIXME', options: (scope: (include: array { 'src/*.cs' }))) s
ORDER BY s.Path, s.LineNumber

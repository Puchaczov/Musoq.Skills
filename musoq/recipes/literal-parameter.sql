param(root: string = '.', needle: string = 'TODO')
SELECT s.Path AS Path, s.LineNumber AS Line
FROM search.lines($root, $needle, options: (scope: (include: array { 'src/*.cs' }))) s
ORDER BY s.Path, s.LineNumber

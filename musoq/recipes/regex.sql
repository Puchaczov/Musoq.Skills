param(root: string = '.')
SELECT s.Path AS Path, s.LineNumber AS Line
FROM search.lines($root, 'TODO|FIXME', options: (
  text: (mode: 'regex'),
  records: (mode: 'physical-line', maxBytes: 1048576),
  scope: (include: array { 'src/*.cs' })
)) s ORDER BY s.Path, s.LineNumber

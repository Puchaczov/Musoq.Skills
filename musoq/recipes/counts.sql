param(root: string = '.')
SELECT c.Path AS Path, c.OccurrenceCount AS Hits
FROM search.counts($root, 'TODO', options: (scope: (include: array { 'src/*.cs' }))) c
ORDER BY c.Path

param(root: string = '.')
SELECT f.Path AS Path
FROM search.files($root, 'dotnet test', options: (scope: (
  include: array { '.github/workflows/*.yml' }, hiddenEntries: true
))) f ORDER BY f.Path

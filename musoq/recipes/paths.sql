param(root: string = '.')
SELECT p.Path AS Path
FROM search.paths($root, options: (scope: (
  include: array { 'src/*.cs', 'src/**/*.cs' },
  exclude: array { '**/obj/**', '**/bin/**', 'src/generated/**' }
))) p ORDER BY p.Path

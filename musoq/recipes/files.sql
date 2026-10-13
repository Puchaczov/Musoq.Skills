param(root: string = '.')
SELECT f.Path AS Path
FROM search.files($root, 'TODO', options: (scope: (
  include: array { 'src/*.cs' }, exclude: array { '**/obj/**', '**/bin/**' }
))) f ORDER BY f.Path

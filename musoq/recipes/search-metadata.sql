-- Question: which nonempty C# files are eligible before reading content?
-- Edit root, globs and metadata constraints. This manifest is not proof of Git tracking.
param(root: string = '.')
SELECT p.Path AS Path FROM search.paths($root, options: (scope: (
 include: array { 'src/*.cs', 'src/**/*.cs' }, exclude: array { 'src/generated/**' },
 metadata: (extensionIncludes: array { '.cs' }, minimumSizeBytes: 1)
))) p ORDER BY p.Path

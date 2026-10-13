param(root: string = '.')
SELECT a.ScopeResolved AS Resolved, a.ScopeExhausted AS Exhausted,
       a.CountsExact AS Exact, a.FilesFailed AS Failed, a.Occurrences AS Hits
FROM search.audit($root, 'NEVER_PRESENT_7291', options: (scope: (include: array { 'src/*.cs' }))) a

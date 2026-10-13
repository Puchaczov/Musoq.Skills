-- Question: is a literal absent anywhere below this root, including hidden/ignored entries?
-- Edit root and needle. This deliberately scans the whole root; use a scoped audit for narrower claims.
param(root: string = '.', needle: string = 'FORBIDDEN_TOKEN')
SELECT a.ScopeResolved AS Resolved, a.ScopeExhausted AS Exhausted,
 a.CountsExact AS Exact, a.FilesFailed AS Failed, a.Occurrences AS Hits
FROM search.audit($root, $needle, options: (scope: (
 hiddenEntries: true, repositoryIgnores: 'disabled'
))) a

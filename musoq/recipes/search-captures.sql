-- Question: how often does each event code appear in matching records?
-- Edit root, regex/group name and scope. Capture expansion can emit multiple rows per match.
param(root: string = '.')
SELECT c.Text AS Code, Count(*) AS Occurrences
FROM search.matches($root, 'code=(?<code>[A-Z][0-9]+)', options: (
 text: (mode: 'regex'), records: (mode: 'physical-line', maxBytes: 1048576),
 scope: (include: array { 'logs/*.log', 'logs/**/*.log' })
)) m CROSS APPLY m.Captures c
WHERE c.GroupName = 'code' AND c.Success = true
GROUP BY c.Text ORDER BY c.Text

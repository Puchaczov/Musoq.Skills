-- Question: what parsed records and malformed candidates occur on ERROR lines?
-- Edit root, prefilter, record schema and scope. ERROR prefilter defines candidate coverage.
-- OUTER APPLY preserves malformed candidates; OccurrenceCount is not extra parser input.
param(root: string = '.')
text LogEntry { Level: token, _: whitespace, Code: token, _: whitespace, Message: rest trim };
SELECT s.Path AS Path, s.LineNumber AS Line, s.LineText AS Raw,
 p.Level AS Level, p.Code AS Code, p.Message AS Message
FROM search.lines($root, 'ERROR', options: (scope: (include: array { 'logs/*.log' }))) s
OUTER APPLY TryParse<LogEntry>(s.LineText) p ORDER BY s.Path, s.LineNumber

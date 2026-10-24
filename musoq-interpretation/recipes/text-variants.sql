text Notice { Trace: optional between '[' ']', Kind: until ':', Message: rest };
SELECT s.Id AS Id, p.Trace AS Trace, p.Kind AS Kind, p.Message AS Message
FROM values { (Id: 1, Line: 'I:ready'), (Id: 2, Line: '[trace-7]W:retry later') } s
CROSS APPLY Parse<Notice>(s.Line) p
ORDER BY s.Id

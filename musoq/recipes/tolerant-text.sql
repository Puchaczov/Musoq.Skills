text Entry { Prefix: literal 'OK:', Message: rest };
SELECT s.Id AS Id, p.Message AS Message
FROM values { (Id: 1, Line: 'OK:ready'), (Id: 2, Line: 'bad') } s
OUTER APPLY TryParse<Entry>(s.Line) p ORDER BY s.Id

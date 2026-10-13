let solution: string = r'Example.sln'
SELECT c.Name AS Class, m.Name AS Method
FROM csharp.solution($solution) s
CROSS APPLY s.Projects p
CROSS APPLY p.Documents d
CROSS APPLY d.Classes c
CROSS APPLY c.Methods m
ORDER BY c.Name, m.Name

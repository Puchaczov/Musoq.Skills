binary Number { Value: int le };
SELECT s.Id AS Id, n.Value AS Value
FROM values { (Id: 1, Hex: '2A000000'), (Id: 2, Hex: '2A') } s
OUTER APPLY TryInterpret<Number>(FromHexToBytes(s.Hex)) n
ORDER BY s.Id

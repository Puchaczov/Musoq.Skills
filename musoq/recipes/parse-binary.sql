binary Header { Value: int le };
WITH bytes AS (SELECT FromHexToBytes('2A000000') AS Data FROM system.dual())
SELECT h.Value AS Value FROM bytes b CROSS APPLY Interpret<Header>(b.Data) h

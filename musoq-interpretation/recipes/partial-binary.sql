binary Reading { Id: byte, Value: ushort le };
let content: byte[] = array { 7ub, 52ub };
SELECT p.ErrorField AS ErrorField, p.BytesConsumed AS BytesConsumed, p.ParsedFields.Id AS Id
FROM values { (Seed: 0) } seed
CROSS APPLY PartialInterpret<Reading>($content) p

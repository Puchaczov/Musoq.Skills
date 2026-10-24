text Entry { Prefix: literal 'OK:', EndMarker: literal '!' };
SELECT p.ErrorField AS ErrorField, p.BytesConsumed AS BytesConsumed, p.ParsedFields.Prefix AS Prefix
FROM values { (Seed: 0) } seed
CROSS APPLY PartialParse<Entry>('OK:x') p

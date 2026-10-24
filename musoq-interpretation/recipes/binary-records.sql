binary ValueBody { Value: ushort le };
binary Item { Id: byte, Size: byte, Payload: substream[Size] as ValueBody };
binary Batch { Count: byte, Items: Item[Count], Trailer: byte };
let content: byte[] = array { 2ub, 7ub, 2ub, 52ub, 18ub, 9ub, 2ub, 2ub, 1ub, 238ub };
SELECT b.Count AS Count, i.Size AS Size, i.Id AS Id, i.Payload.Value AS Value, b.Trailer AS Trailer
FROM values { (Seed: 0) } seed
CROSS APPLY Interpret<Batch>($content) b
CROSS APPLY b.Items i
ORDER BY i.Id

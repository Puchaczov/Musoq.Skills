text Pair { Key: until '=', Value: rest };
binary Envelope { Size: byte, Payload: string[Size] ascii as Pair, Trailer: byte };
let content: byte[] = array { 5ub, 107ub, 61ub, 111ub, 97ub, 107ub, 127ub };
SELECT e.Size AS Size, e.Payload.Key AS Key, e.Payload.Value AS Value, e.Trailer AS Trailer
FROM values { (Seed: 0) } seed
CROSS APPLY Interpret<Envelope>($content) e

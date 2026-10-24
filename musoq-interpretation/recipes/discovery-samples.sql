binary Candidate { CandidateLength: ushort le, Raw: byte[2] };
SELECT s.Id AS Id, p.CandidateLength AS CandidateLength
FROM values { (Id: 1, Hex: '02001122'), (Id: 2, Hex: '02003344'), (Id: 3, Hex: '0200AABB') } s
CROSS APPLY Interpret<Candidate>(FromHexToBytes(s.Hex)) p
ORDER BY s.Id

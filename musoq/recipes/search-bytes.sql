-- Question: where does a byte signature occur, independent of text decoding?
-- Edit root, hex signature and scope. Offsets refer to original bytes, not characters.
param(root: string = '.')
SELECT b.Path AS Path, b.ByteOffset AS Offset, b.ByteLength AS Length
FROM search.bytes($root, 'CAFE', options: (scope: (include: array { 'binary/*.bin' }))) b
ORDER BY b.Path, b.ByteOffset

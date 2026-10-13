-- Question: which explicitly delimited records contain a multiline pattern?
-- Edit delimiters, regex, maxBytes and scope. Unterminated/oversized records must be diagnosed.
param(root: string = '.')
SELECT m.Path AS Path, m.LineNumber AS Line, m.MatchText AS Match
FROM search.matches($root, '(?s)ERROR.*failure', options: (
 text: (mode: 'regex'), records: (mode: 'bounded-multiline', maxBytes: 4096,
  startDelimiter: 'BEGIN', endDelimiter: 'END', allowUnterminatedEof: false),
 scope: (include: array { 'multiline/*.txt' })
)) m ORDER BY m.Path, m.MatchIndex

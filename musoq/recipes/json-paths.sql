SELECT j.Path AS Path, j.Value AS Value
FROM stdin.JsonFlat() j
WHERE j.Path = 'user.name' OR j.Path = 'tags[0]'
ORDER BY j.Path

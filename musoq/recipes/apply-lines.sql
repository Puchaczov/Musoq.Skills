SELECT line.Value AS Value
FROM stdin.TextBlock() text
CROSS APPLY text.SplitByNewLines(text.Value) line

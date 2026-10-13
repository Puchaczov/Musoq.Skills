param(root: string = '.')
SELECT f.Extension AS Extension, Count(*) AS Files, Sum(f.Length) AS Bytes
FROM os.files($root, false) f
GROUP BY f.Extension ORDER BY f.Extension

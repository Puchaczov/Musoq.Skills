WITH ranked AS (
 SELECT s.Category AS Category, s.Name AS Name, s.Score AS Score,
        ROW_NUMBER() OVER (PARTITION BY s.Category ORDER BY s.Score DESC, s.Name) AS Position
 FROM values {
   (Category: 'Books', Name: 'A', Score: 30), (Category: 'Books', Name: 'B', Score: 10),
   (Category: 'Games', Name: 'C', Score: 20), (Category: 'Games', Name: 'D', Score: 15)
 } s
)
SELECT Category, Name, Score, Position FROM ranked WHERE Position = 1 ORDER BY Category

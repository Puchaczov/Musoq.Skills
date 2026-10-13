SELECT s.Component AS Component, Count(*) AS Total,
       Count(*) FILTER (WHERE s.Level = 'ERROR') AS Errors
FROM values {
  (Component: 'api', Level: 'INFO'), (Component: 'api', Level: 'ERROR'),
  (Component: 'worker', Level: 'INFO')
} s GROUP BY s.Component ORDER BY s.Component

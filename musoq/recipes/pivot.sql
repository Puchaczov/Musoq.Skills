WITH events AS (
 SELECT e.Component AS Component, e.Level AS Level
 FROM values {
  (Component: 'api', Level: 'INFO'), (Component: 'api', Level: 'ERROR'),
  (Component: 'worker', Level: 'INFO')
 } e
)
PIVOT events
ON Level IN ('INFO' AS Info, 'ERROR' AS Errors)
USING Count(*) AS Events
GROUP BY Component
ORDER BY Component

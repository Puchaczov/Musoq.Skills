text FixtureLine { Level: token, _: whitespace, Message: rest };
SELECT p.Level AS Level, p.Message AS Message
FROM system.dual() seed CROSS APPLY Parse<FixtureLine>('INFO ready') p

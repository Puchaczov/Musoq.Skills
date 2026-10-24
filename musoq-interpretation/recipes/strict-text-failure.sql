text Entry { Prefix: literal 'OK:', Message: rest };
SELECT p.Message AS Message FROM values { (Seed: 0) } seed CROSS APPLY Parse<Entry>('bad') p

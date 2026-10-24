binary Number { Value: int le };
let content: byte[] = array { 42ub };
SELECT n.Value AS Value FROM values { (Seed: 0) } seed CROSS APPLY Interpret<Number>($content) n

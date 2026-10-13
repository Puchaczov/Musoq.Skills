param(root: string = '.')
SELECT c.MessageShort AS Subject
FROM git.commits($root) c ORDER BY c.CommittedWhen DESC TAKE 2


arith --->
  doc =
    == Redefining arithmetic
    You may redefine arithmetic operators as you see fit. The
    modifications are only valid in the scope where they are defined.
    Be careful not to use addition inside a redefinition of addition,
    however.
  code =
    100 + 10 where a + b = a - b

markdown --->
  doc =
    == Markdown
    You can import and use any package you want in the REPL. Why not
    Markdown?
  code =
    require: markdown -> parse
    raw % parse{"Isn't this **cool**?"}


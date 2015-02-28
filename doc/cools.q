
arith ---> Redefining arithmetic --->
  doc =

    You may redefine arithmetic operators as you see fit. The
    modifications are only valid in the scope where they are defined.

  code =
    100 + 10 where a + b = a - b

markdown ---> Markdown --->
  doc =

    _1 <- `http://daringfireball.net/projects/markdown/syntax

    Let's display some Markdown::{_1}~! It is really quite simple,
    first import the `markdown package, generate the HTML with `parse,
    and use `[raw % html] to render it.

  code =
    require: markdown -> parse
    raw % parse{"Isn't this **cool**?"}

multiplication ---> A multiplication table --->
  doc =

    The `[%] operator in Earl Grey can be used to build HTML. So let's
    generate a multiplication table!

  code =

    table % 1..10 each i ->
       tr % 1..10 each j ->
          td % i * j

flot ---> Plotting with flot --->
  doc =

    _1 <- `http://www.flotcharts.org/

    This code will draw a nice plot using flot::{_1}.
    `require will not work here, unfortunately, but
    we can still load the scripts.

  code =

    load "https://code.jquery.com/jquery-2.1.3.min.js"
    load "http://www.flotcharts.org/flot/jquery.flot.js"
    globals: $
    $out.elem.style.height = "500px" ;; making room
    $.plot{$out.elem, {p1, p2, p3}} where
       p1 = 1..100 each i -> {i, Math.sin{i / 10}}
       p2 = 1..100 each i -> {i, Math.sin{i / 10 - 1}}
       p3 = 1..100 each i -> {i, Math.sin{i / 10} + 0.25}
    undefined


wait ---> WAIT --->
  doc =
     WAIT
  code =
     await wait{2000}

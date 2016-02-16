
template :: default

meta ::
  title = Try Earl Grey!
  author = Olivier Breuleux
  summary = REPL for Earl Grey.

resources ::
  style/repl.sass
  https://jspm.io/system@0.19.js


inherit.cool#cool-arith % &
  ;; Look! I'm redefining addition! (locally)
  100 + 10 where
     a + b = a - b

inherit.cool#cool-curry % &
  ;; Currying a function using an external library
  ;; This could take a few seconds to load, be patient    
  require: lodash -> curry
  curry! add(x, y) =
     x + y
  {1, 2, 3}.map(add(10))

inherit.cool#cool-markdown % &
  ;; Parsing and displaying Markdown
  ;; This could take a few seconds to load, be patient
  require: markdown -> parse
  grocery-list = """
  Grocery list
  ------------
  * Potatoes
  * Rice
  * SPAM
  """
  div[raw] % parse(grocery-list)

inherit.cool#cool-flot % &
  ;; Plotting with flot
  ;; This could take a few seconds to load, be patient
  load "https://code.jquery.com/jquery-2.1.3.min.js"
  load "http://www.flotcharts.org/flot/jquery.flot.js"
  globals: $
  $out.elem.style.height = "500px" ;; making room
  $.plot($out.elem) with {
     1..100 each i -> {i, Math.sin(i / 10)}
     1..100 each i -> {i, Math.sin(i / 10 - 1)}
     1..100 each i -> {i, Math.sin(i / 10) + 0.25}
  }
  undefined

inherit.cool#cool-paint % &
  ;; Trivial canvas-based paint app
  ;; Try setting the color with ctx.stroke-style = "red"
  require: offset
  var active = false
  offx(e) = e.client-x - offset(canvas).left
  offy(e) = e.client-y - offset(canvas).top
  canvas = dom with canvas %
     width and height = "300px"
     style = "border:2px solid black; cursor:crosshair"
     onmousedown(e) =
        active = true
        ctx.begin-path()
        ctx.move-to(offx(e), offy(e))
     (onmouseup and onmouseout)(e) =
        active = false
     onmousemove(e) =
        if active:
           ctx.line-to(offx(e), offy(e))
           ctx.stroke()
  ctx = canvas.get-context("2d")
  ctx.line-width = 3
  print canvas
  undefined

inherit.cool#cool-snake % &
  ;; snake game. Sorry for the code density, I code-golfed it a bit.
  require: /dom
  snake(len, tl, interval) =
     map = 1..len each x -> 1..len each y -> 0
     r() = Math.floor(Math.random() * len)
     spwn(value and {x, y} is {r(), r()}) =
        if{map[x][y], spwn(value), (map[x][y] = value, {x, y})}
     var {{px, py}, dx, dy, score} = {spwn{1}, 0, 0, 0}
     1..5 each i -> spwn(-1)
     canvas = dom with canvas %
        width and height = '{len * tl}px'
        tabindex = 1000
        onkeydown(e) =
           e.prevent-default()
           {dx, dy} = {39={1,0},37={-1,0},40={0,1},38={0,-1}}[e.which]
     ctx = canvas.get-context("2d")
     loop = set-interval(f, interval) where f() =
        map[px][py] = score + 1
        {px, py} = {u(px,dx), u(py,dy)} where u(p,d) = (p+d+len) mod len
        if dx or dy: match map[px][py]:
           < 0 -> (spwn(-1); score += 1)
           > 0 -> (print 'Game Over! {score} points!'; clear-interval(loop))
           0 -> 0...len each x -> 0...len each y when map[x][y]>0 -> map[x][y]-=1
        map[px][py] = score + 1
        ctx.clear-rect(0, 0, canvas.width, canvas.height)
        0...len each x -> 0...len each y when map[x][y] ->
           ctx.fill-style = if{map[x][y] < 0, .blue, .red}
           ctx.fill-rect(tl * x, tl * y, tl, tl)
     set-timeout(-> canvas.focus(), 10)
     print "Snake: use arrow keys to move"
     print canvas
  snake(15, 30, 150)
  undefined


js ::
  function $enlarge(objects) {
    h = Math.max(window.innerHeight - 150, 500) + "px";
    document.querySelector(".repple-repl").style.height = h;
    document.querySelector(".repple-aside").style.height = h;
    console.log(objects);
    objects.repl.cm.focus();
  }


repple repl-aside ::

  language = earlgrey

  after = $enlarge

  code =>
    globals:
       System
       document

    wait = promisify with {d, f} ->
       set-timeout.call{null, f, d}

    normalize-module-name{match} =
       RegExp{"^raw:"}? x -> x.slice{4}
       RegExp{":"}? x -> x
       x -> "npm:" + x

    _cool-cycle = document.query-selector-all{"pre.cool"} each elem ->
       elem.id[5...]

    _cool{match} =
       false? ->
          name = _cool-cycle.shift{}
          _cool-cycle.push{name}
          _cool{name}
       name ->
          code = document.get-element-by-id{'cool-{name}'}.text-content
          $repl.process{code, true, true}

    inline-macro cool{match name}:
      #void{} ->
         `_cool{}`
      else ->
         `_cool{^name}`

    inline-macro next{_}:
      `show-card{"tut", null}`

    inline-macro __require{#data{expr}}:
       ```
       await System.import{normalize-module-name{^expr}}
       ```

    inline-macro print{match expr}:
       `^expr in ^[#symbol{target}]` ->
          ```
          t = ^expr
          Outputter{document.get-element-by-id{^=target}, true}.log{t}
          t
          ```
       else ->
          `t = ^expr, $out.log{t}, t`

    _load{match url} =
       R".js$"? ->
          new Promise with {resolve, reject} ->
             document.getElementsByTagName{"head"}[0].appendChild with
                dom with script %
                   async = true
                   type = "text/javascript"
                   src = url
                   onload{} = resolve{undefined}
       R".css$"? ->
          document.getElementsByTagName{"head"}[0].appendChild with
             dom with link %
                rel = "stylesheet"
                type = "text/css"
                href = url
          undefined
       else ->
          throw E.unknown_resource_type{url}

    inline-macro load{url}:
       `await _load{^url}`

    next

  +tut =
    +10-start-The Earl Grey programming language =>
      | `Enter or `[Ctrl-Enter]             | Evaluate an expression
      | `[Shift-Enter]                      | Insert a new line
      | `[Up/Down] or `[Ctrl-Up/Ctrl-Down]  | Navigate history
      | `[Ctrl-L]                           | Clear the screen
    
      Alright, so you have stumbled upon this page for some reason.
    
      Good! Stay right here!
    
      .big % __ Start with the tutorial: /next
      .big % __ Just show me cool stuff: /cool

    +20-expressions-Variables and expressions =>
    
      .note %
        For the purpose of this tutorial, I will assume you are already
        familiar with an existing language such as JavaScript, Python or
        Ruby, which have a similar feature set.
    
      How should one start a tutorial, usually? Man, I don't know. But I
      know there are two very useful things programming languages can do:
    
      # __[Doing math!] Like /[1 + 1] (<- psst! you can _click these!) You can
        do math with Earl Grey. The operator precedence you learned at
        school (well I hope you did) will work just fine: (`mod is modulo)
    
        / 99 + 7 * (18 - 3) mod 10
    
      # __[Putting stuff in variables!] Sometimes you just need to put
        something in a variable so that you can use it later. A variable
        can contain dashes:
    
        / my-variable = 1 + 2 + 3
    
        Why don't you put your name in a variable so you won't forget it?
        A string is delimited by double quotes. My name is /"Olivier" for
        example.
    
      Type /next to get to the next topic.
    
    
    +30-arrays-Arrays =>
    
      Variables are nice, but a variable can only hold one thing, and
      that's a bummer. If only there was a way to hold more than one thing
      in a thing.
    
      Oh, that's right, there is!
    
      __Arrays store sequences of things. An array in Earl Grey is denoted
      by curly braces:
    
      * Empty array: /{}
      * Array of numbers: /{12, 87, -4}
      * Array of stuff: /{"Hello", 123, {"nested", "things", 10 * 10}}
    
      Accessing members of an array may be done using square brackets,
      starting from zero: /{18, 9, 71}[0]. You can also omit the brackets:
      /[{18, 9, 71} 0].
    
      Type /next to get to the next topic.
    
    
    +31-arrays2-...Arrays =>
    
      Now, what can you do on arrays? Well, all operations supported in
      JavaScript are also supported, and the syntax is the same. See
      here@@{aops} for a list. This being said, EG defines a few
      additional operations and shortcuts:
    
      (Reminder: you can click these)
    
      div.blocks %
        / {1, 2, 3, 4}.reverse()
        / {1, 2} ++ {5, 6}
        / {10, 8, 71, 13, 24}[2...]
        / {10, 8, 71, 13, 24}[... -2]
        / {10, 8, 71, 13, 24}[2 ... -2]
        / enumerate({53, 87, -22, 41})
        / neighbours({53, 87, -22, 41})
        / zip({1, 2, 3, 4}, {11, 22, 33, 44})
        / {1, 2, 3, 4, 5} each x -> x * x
    
      aops => https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array
      Type /next to get to the next topic.
    
    
    +40-objects-Objects =>
    
      __Objects map _names, which are strings, numbers or symbols, to
      _stuff, which can be anything. Like arrays, objects are declared
      with curly brackets, but with the addition of the `[=] or `[=>]
      operator:
    
      * Empty object: /{=}
      * My name and age: /{name = "Olivier", age = 30}
      * Also acceptable: /{"name" => "Olivier", "age" => 30}
    
      To get the value of an object's field, use square brackets, the dot
      operator, or nothing at all:
    
      * / {name = "Olivier"}["name"]
      * / {name = "Olivier"} "name"
      * / {name = "Olivier"}.name
    
      .note %
        /[.name] and /"name" are actually the same thing. If a string could
        be a variable name, then you can put a dot in front instead of quotes
        around it.
    
      Type /next to get to the next topic.
    
    
    +50-functions-Functions =>
    
      Numbers, strings, arrays and objects are amazing, but you won't get
      very far without better abstractions. A __function lets you
      encapsulate behavior so that you don't repeat yourself. For
      instance, define a function to square a number:
    
      / square(x) = x * x
    
      Simple, eh? You can use it like this: /square(5). And if you want to
      define a long function, then you can _indent the body:
    
      / square(x) =
           print 'I am squaring {x}!'
           x * x
    
      Type /next to get to the next topic.
    
    +51-functions2-...Functions =>
    
      Sometimes you may need to give a function to another function to do
      stuff. For example, the `for-each method of arrays takes a function
      to call on every member of the array.
    
      Depending on the situation, there are four ways to do it. Yes,
      four. Do you have a problem with that?
    
      # [Declare a named function, especially if you need it elsewhere:]
    
        / f(x) = print x
          {1, 2, 3}.for-each(f)
    
      # [Inline, for small functions]
    
        / {1, 2, 3}.for-each(x -> print x)
    
      # [`with operator, to avoid brackets and indent the body, when the function is the last argument]
    
        / {1, 2, 3}.for-each with x ->
             print x
    
      # [`where operator, if it is clearer\/more practical to name the function, especially when the function isn't the last argument]
    
        / print "watch for it..."
          set-timeout(f, 1000) where f() =
             print "there it is!"
    
      Type /next to get to the next topic.
    
    
    +60-conditions-Conditions =>
    
      __[`if] executes code conditionally. Its syntax is the same as in
      Python:
    
      / if 1 + 1 == 2:
           "Everything is fine!"
        elif 2 + 2 == 4:
           "I think this was just a fluke."
        else:
           "Oh no! Mathematics are falling apart!"
    
      `if returns its result. There is also an alternative syntax for
      one-liners:
    
      / if{1 + 1 == 2, "yay", "boooo!"}
    
      Type /next to get to the next topic.
    
    
    +70-loops-Loops =>
    
      __[`while] loops work as they do in Python:
    
      / var i = 10
        while i >= 0:
           print i
           i -= 1
    
      Note that the `var keyword is necessary above because `i is a
      mutable variable.
    
      C-style `for loops are available, if for some reason you want to use
      them:
    
      / for (var i = 10; i >= 0; i--): print i
    
      `break and `continue inside loops work as they do in other
      languages.
    
      Type /next to get to the next topic.
    
    
    +71-loops2-...Loops =>
    
      The __[`each] operator is the generic way to loop over sequences
      such as arrays or ranges.
    
      / 1..100 each i -> i * i
    
      `each accepts an indented block, but also multiple _clauses,
      executed in order. A "clause" maps some kind of pattern to a
      body. There are many kinds of patterns. Can you figure out what
      these do? (click to verify)
    
      / {1, "banana", 6, {98}, {2, 3}, "mess", {=}} each
           Number? i                       -> i + 1
           String? s when s.ends-with("s") -> s + "es"
           String? s                       -> s + "s"
           {x}                             -> x + 1
           {x, y}                          -> x + y
           else                            -> null
    
      `break and `continue can be used to manipulate the stopping
      condition and the results. For instance, this computes the squares
      of odd numbers less than ten:
    
      / 1..100000 each
           i when i > 10 ->
              break
           i when i mod 2 == 0 ->
              continue
           i ->
              i * i
    
      Type /next to get to the next topic.
    
    
    
    +80-patterns-Pattern matching =>
    
      As you just saw, `each's clauses let you match patterns against
      values. But you can do that almost everywhere in EG! It would be
      long to explain all possible patterns, but all these examples should
      give you an idea:
    
      .blocks %
        / {x, {y, z}} = {1, {2, 3}}
        / {x, 5} = {1, 2}   ;; This will fail!
        / String? s = 4     ;; This will fail!
        / Array! a = 4      ;; *Create* an array if needed
        / n > 0 = 8         ;; Try with -1 instead of 8
        / double(Number! x) = x + x
          double! x = "9"
        / {x} or x = 9      ;; Try with {9} instead of 9
        / a and b = 100     ;; Set two variables at the same time
        / {=> name} = {name = "Peter"}
        / {p1 => {x => x1, y => y1}, p2 => {x => x2, y => y2}} =
             {p1 = {x = 1, y = 1}, p2 = {x = 8, y = 3}}
    
      Type /next to get to the next topic.
    
    
    +81-patterns2-...Pattern matching =>
    
      `match specializes in matching:
    
      / match {7, 8}:
           {} -> 0
           {x} -> x
           {x, y} -> x + y
    
      Sometimes it can be useful to match on a function argument
      immediately, so as shorthand you can put the `match keyword directly
      _inside the arguments list:
    
      / fact(match) =
           0 -> 1
           n -> n * fact(n - 1)
        fact(10)
    
      You can nest `match inside patterns indefinitely:
    
      / silly(match, y) =
           {match} -> {match} -> {match} -> x -> x * y
        silly({{{5}}}, 7)
    
      .tip %
        The same trick can be used with `each:
    
        / square(each x) = x * x
          square(1..10)
    
      Type /next to get to the next topic.
    
    
    +90-documents-Documents =>
    
      EG comes with a mini-language to define "documents". Assuming you
      know HTML, it is relatively straightforward:
    
      / strong % "I AM YELLING!"
    
      / span[raw] % "<em>this works in a pinch</em>"
    
      / ol %
           type = "i"
           li % "Collect Underpants"
           li % "?"
           li % "Profit"
    
      / .card %
           style = "border: 5px solid black;"
           h2 % "This is not part of the tutorial!"
           p % "Do you know your multiplication table?"
           table % 1..10 each row ->
              tr % 1..10 each col ->
                 td % row * col
    
      These objects can be converted to HTML with the `[/html] package:
    
      / require: /html
        html(em % "hello")
    
      Type /next to get to the next topic.
    
    
    +100-libraries-Libraries =>
    
      Use `require to import libraries. If you use it here, it will import
      from the `npm repositories. Pretty neat! (Give a few seconds for the
      package to be fetched the first time, it can be a bit slow).
    
      / require: markdown
        div[raw] % markdown.parse("This *works*! Yay!")
    
      You can check the contents of the package just by typing /markdown.
    
      Type /next to get to the next topic.
    
    
    +110-async-Asynchronous programming =>
    
      Sometimes you need to wait for data, or for some event to happen in
      order to keep doing something. Maybe you're waiting for a file to be
      read from the hard drive, for a file to be retrieved online, for a
      database transaction to complete, and so on. And while you wait, you
      don't want to stop the whole application, that would just be silly!
    
      Enter asynchronous programming.
    
      .note %
         By default the interactive interpreter will wait for an
         asynchronous call to finish before yielding back control to you.
         If you want to avoid waiting, the trick is to wrap the call(s) in
         [`{}]s.
    
      An asynchronous function is marked with the keyword `async, and it
      can freely wait on any sub-operation with `await.
    
      / async f(seconds) =
           await wait(seconds * 1000)
           print 'I have waited {seconds} seconds.'
        {f{5}, f{1}, f{2}}
    
      Notice that the above does not take 8 seconds to finish, as one
      would expect from purely sequential execution. Each operation
      finishes in its own time.
    
      EG's implementation is based on ES6's generators and promises, but
      it looks much nicer :\) If a library function advertises that it
      returns a Promise object, then `await will work.
    
      .note %
        A lot of functionality, especially in the node ecosystem, uses a
        different (horrendous) interface based on callbacks. Thankfully,
        assuming they follow protocol, these functions can be converted
        with the `promisify builtin.
    
      Type /next to get to the next topic.
    
    
    +1000-end-The End =>
    
      The tutorial is over :\)
    
      You can restart it with /next, or simply keep playing around in the
      interactive interpreter. Cheers!


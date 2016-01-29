
template :: default

meta ::
   title = Earl Grey
   author = Olivier Breuleux
   summary = Introduction to the Earl Grey language.

;; js :: document.getElementById("logo").className = "navlink curnav"

[\label _@@ \url] => __[{label} @@ {url}]
[@@! \project] => {project} _@@ https://github.com/breuleux/{project}

__[Earl Grey] is a neat little language that compiles to
JavaScript. Here's what it has to offer:

* [Concise and streamlined syntax _@@ #whatdoesitlooklike] inspired
  by the Python language.
* Fully [compatible _@@ #compatible] with the node.js ecosystem
* Generators and [async/await _@@ #asyncawait] (no callback hell!)
* Powerful, deeply integrated [pattern matching _@@ #patternmatching]
  * Used for assignment, function declaration, looping, exceptions...
* A [document-building DSL _@@ #documentbuilding] with customizable behavior!
* A very powerful hygienic [macro _@@ #macrosystem] system!
  * Define your own control structures or DSLs
  * Macros integrate seamlessly with the language
  * Macro libraries! Test with @@!earl-mocha, build with @@!earl-gulp,
    make dynamic pages with @@!earl-react, etc.
* And [much more! _@@ #resources]

Earl Grey is still in development, be sure to
[star it on GitHub]_@@https://github.com/breuleux/earl-grey
to show some support!

Also be sure to check out the [interactive tutorial _@@ {siteroot}repl].


== What does it look like?

Earl Grey is whitespace sensitive: _indent defines blocks and line
breaks separate statements. This reduces the punctuation noise often
seen in other languages in the form of braces and semicolons.

Parts of the language will be very familiar to Python users, for
instance this excerpt of a cutting edge rocket launching application
in Earl Grey:

&  var i = 10
   while i >= 0:
      if i == 0:
         print "Blast off!"
      else:
         print i
      i--

But EG also takes steps towards a "streamlined" design that removes
many of the spurious distinctions other languages make, for instance
the distinction between expressions and statements, variable and
function declarations, or loops and list comprehensions (which share
the same syntax in EG):

&  fib(n) =
      var {a, b} = {1, 1}
      1..n each i ->
         {a, b} = {b, a + b}
      a

   fibs = 0..10 each i -> fib(i)
   print 'The first ten fibonacci numbers are {fibs.join(", ")}'

You can read more about EG's many features in the
[documentation @@@ doc.html].


== Compatible

One of EG's primary goals is to be as compatible as possible with
existing JavaScript libraries and frameworks and the node ecosystem.

Any package in npm's wide selection can thus be imported and used
without issue. The same goes for jQuery, canvas/SVG libraries, or
frameworks such as React. Conversely, EG can be used to create
packages that JavaScript code may import and use.

EG has support for source maps. Plugins exist for a few existing
frameworks: @@!gulp-earl for gulp, @@!earlify for browserify.

==== Tooling

Editor support is admittedly mediocre at the moment, but it is in
development:

* __Emacs: @@!earl-grey-mode

* __Atom: language-earl-grey _@@ //atom.io/packages/language-earl-grey



== async/await

EG makes asynchronous code a breeze. EG's implementation is based on
Promises as defined by ECMAScript version 6 and many libraries already
implement this interface. For the rest, existing callback-based
functionality can be converted to Promises using `promisify.

To give you an idea here is a script to print the alt-text of the
first ten XKCD@@http://xkcd.com comics, accessed through their JSON API:

&   require: request
    g = promisify(request.get)

    async getXKCD(n = "") =
       response = await g('http://xkcd.com/{n}/info.0.json')
       JSON.parse(response.body)

    async:
       requests = await all 1..10 each i -> getXKCD(i)
       requests each req -> print req.alt

Calls to `getXKCD or `g are asynchronous, which means that they don't
block. The code above will therefore fetch the data for the first ten
XKCD comics in parallel*, not sequentially. `await all` collects the
results for us, returning only when everything is done (and then we
can print them in order).

\* Do note that this is only IO parallelism, not _true
parallelism. You cannot use async/await to run ten matrix
multiplications in parallel on different threads or different
processors unless you explicitly create these threads (or web
workers), or use a library that does.


== Pattern matching

Pattern matching is the kind of feature that you can't tolerate not
having, once you have a taste of it. A lot of languages implement
crippled versions of it (usually as destructuring assignment). EG
gives you _everything (short of actual static guarantees, but I'm
thinking about it).

`match can serve as a `switch or `case statement:

&  fact(n) =
      match n:
         0 -> 1
         1 -> 1
         n -> n * fact(n - 1)

But we can do better:

&  fact(match) =
      0 or 1 -> 1
      n -> n * fact(n - 1)

We can extract elements from arrays:

&  match process.argv[2..]:
      {"install", name}     -> ...
      {"list", query = "*"} -> ...
      {"version"}           -> ...
      ...

From objects:

&  point = {x = 2, y = 3}
   {=> x, => y} = point   ;; x is 2, y is 3

We can do type checking and type coercion:

&  String? "abc"           ;; ==> true
   Array! "abc"            ;; ==> {"abc"}

   repeat(String? thing or Array! thing, Number? match) =
      0 -> {}
      n -> thing.concat(repeat(thing, n - 1))
   
   repeat("hello", 4)      ;; ==> "hellohellohellohello"
   repeat({1, 2}, 2)       ;; ==> {1, 2, 1, 2}
   repeat(6, 3)            ;; ==> {6, 6, 6}
   repeat("apple", "pie")  ;; ==> ERROR

More exhaustive documentation can be found
[here @@@ doc.html#patternmatching].


== Document building

Earl Grey's `[%] operator can be used to easily build HTML, DOM,
virtual DOM, and other things:

&  mul-table =
      div[#multiplication-table] %
         h1 % "Multiplication table"
         table % 1..10 each i ->
            tr % 1..10 each j ->
               td % i * j

The resulting data structure can then be transformed in various ways.
For instance, you can use the `[/html] and `[/dom] standard packages:

`html builds a string of HTML that you can print or save in a file:

&  require: /html
   print html(mul-table)

`dom builds a DOM element that you can append somewhere in your page:

&  require: /dom
   document.get-element-by-id("target").append-child(dom(mul-table))

You can also streamline the operation by importing a specialized `[%]
operator to do what you want automatically:

&  require-macros: /html -> (%)
   print strong % "Hello world" ;; ==> "<strong>Hello world</strong>"

=== React

In addition to HTML and plain DOM conversions, there is also a
react_@@{react} package for Earl Grey called @@!earl-react from which
you can import a `[%] operator that builds React virtual DOM nodes:

react => https://facebook.github.io/react/

&  require: earl-react as React
   require-macros: earl-react -> (%, component)
   component HelloMessage:
      render() = div % 'Hello {@props.name}'
   React.render(HelloMessage % name = "Balthazar", mount-node)

It would be straightforward to define `[%] for other frameworks, or
for new ones, or to generate other languages such as LaTeX.


== Macro system

EG's macro system permits the definition of new control structures
that look native to the language. Macros are fairly easy to write and
can make code terser and more readable:

&  inline-macro W(expr):
      `(^expr).split(" ")`

   W"apples bananas cantaloupes" ;; ==> {"apples", "bananas", "cantaloupes"}


&  inline-macro unless(`{^test, ^body}`):
      `if{not ^test, ^body}`

   unless 1 == 2:
      print "Everything is fine!"

At the moment I have not yet well documented the macro system, but
there is still some documentation [here @@@ doc.html#macros].


=== Macro libraries

It is possible to define macro libraries with macros importable via
`require-macros.

In fact, there are _already macro libraries for many existing
JavaScript or node libraries! Here are some of them:


=== Test with earl-mocha

@@!earl-mocha defines a certain amount of macros to help you write
tests for your applications:

&  require-macros:
      earl-mocha -> (describe, it, assert, expect-error)

   describe "Array":

      it "#concat":
         assert {1, 2}.concat({3, 4}) == {1, 2, 3, 4}

      it "#map":
         assert {1, 2, 3}.map(x -> x * x) == {1, 4, 9}
         expect-error TypeError:
            {1, 2, 3}.map("huh")


=== Build with earl-gulp

Using @@!earl-gulp, you can define gulp tasks like this:

&   require-macros: earl-gulp -> task

    require: gulp, gulp-sass, gulp-earl, gulp-sourcemaps

    task sass:
       chain gulp:
          @src("./content/**/*.sass")
          @pipe(gulp-sass(indented-syntax = true))
          @pipe(gulp.dest("./output"))

    task earl:
       chain gulp:
          @src("./content/**/*.eg")
          @pipe(gulp-sourcemaps.init())
          @pipe(gulp-earl())
          @pipe(gulp-sourcemaps.write("./"))
          @pipe(gulp.dest("./output"))

    task default < {earl, sass}


=== Make pages with earl-react

React has its own little language called JSX to define components, but
there's no need for this when you have @@!earl-react:

&   require: earl-react as React
    require-macros: earl-react -> (%, component)
    globals: document

    component TodoList:
       render() =
          ul % enumerate(@props.items) each {i, item} ->
             li % item
    
    component TodoApp:
       get-initial-state() = {items = {}, text = ""}
       render() =
          div %
             h3 % "TODO"
             TodoList % items = @state.items
             form %
                on-submit(e) =
                   e.prevent-default()
                   @set-state with {
                      items = @state.items.concat({@state.text})
                      text = ""
                   }
                input %
                   value = @state.text
                   on-change(e) =
                      @set-state with {text = e.target.value}
                button % 'Add #{@state.items.length + 1}'

    React.render(TodoApp % (), document.get-element-by-id("mount"))


= Resources

* Source code _@@ https://github.com/breuleux/earl-grey

* Report an issue _@@ https://github.com/breuleux/earl-grey/issues

* Install Earl Grey _@@ {siteroot}use.html

* Editor/syntax highlighting support _@@ {siteroot}tooling.html

* Go through the [interactive tutorial _@@ {siteroot}repl]. It
  runs in your browser, no need to install anything!

* See the [documentation _@@ {siteroot}doc.html] for an overview of
  all of EG's features.

* Contribute! _@@ {siteroot}contrib.html

* Follow us on twitter! {twitter}

* Join the gitter chat! {gitter}

* Or join the `[#earlgrey] channel on FreeNode.



gitter =>
  html :: <a href="https://gitter.im/breuleux/earl-grey?utm_source=badge&amp;utm_medium=badge&amp;utm_campaign=pr-badge&amp;utm_content=badge"><img src="https://camo.githubusercontent.com/da2edb525cde1455a622c58c0effc3a90b9a181c/68747470733a2f2f6261646765732e6769747465722e696d2f4a6f696e253230436861742e737667" alt="Join the chat at https://gitter.im/breuleux/earl-grey" data-canonical-src="https://badges.gitter.im/Join%20Chat.svg" style="max-width:100%;"></a>

twitter =>
   html ::
      <a href="https://twitter.com/earlgreylang" class="twitter-follow-button" data-show-count="false">Follow @earlgreylang</a>
      <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>

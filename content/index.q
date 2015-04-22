
meta ::
   title = Earl Grey
   author = Olivier Breuleux
   summary =
      Introduction to the Earl Grey language.
   template = default


js :: document.getElementById("logo").className = "navlink curnav"

[\label _@@ \url] => __[{label} @@ {url}]
[\maybe\text @@@ \maybe\path] => {text}@@{siteroot}{path}

__[Earl Grey] is a neat little language that compiles to
JavaScript. Here's what it has to offer:

* [Python-like syntax _@@ #pythonlikesyntax]
* Fully [compatible _@@ #compatible] with the node.js ecosystem
* Generators and [async/await _@@ #asyncawait] (no callback hell!)
* Powerful, deeply integrated [pattern matching _@@ #patternmatching]
  * Used for assignment, function declaration, looping, exceptions...
* A DOM-building DSL with customizable behavior
* A very powerful hygienic [macro _@@ #macrosystem] system that allows you to define:
  * Your own control structures!
  * New kinds of patterns for the pattern matcher!
  * Modifiers that apply to the rest of a block!
  * New kinds of macros!
* And much more!


== Python-like syntax

Like Python, EG uses indent to define blocks and line breaks to
separate statements, which reduces punctuation noise. Several control
structures, for instance conditionals and `while loops, will be
perfectly familiar to Python users:

&  var i = 10
   while i > 0:
      if i == 0:
         print "Blast off!"
      else:
         print i

The rest of the language is less similar but retains a simple feel and
consistent, minimalist syntax:

&  fib(n) =
      var {a, b} = {1, 1}
      for i of 1..n:
         {a, b} = {b, a + b}
      a
   
   1..10 each i ->
      print fib(i)

EG's features are too numerous to list here, but you can read about
them in the [documentation @@@ doc.html].


== Compatible

One of EG's primary goals is to be as compatible as possible with
existing JavaScript libraries and frameworks and the node/iojs
ecosystem.

Any package in npm's wide selection can thus be imported and used
without issue. The same goes for jQuery, canvas/SVG libraries, or
frameworks such as React. Conversely, EG can be used to create
packages that JavaScript code may import and use.

EG has support for source maps. Plugins exist for a few existing
frameworks: [gulp-earl]@@{L1} for gulp, earlify@@{L2} for browserify.

L1 => https://github.com/breuleux/gulp-earl
L2 => https://github.com/breuleux/earlify


== async/await

EG makes asynchronous code a breeze. EG's implementation is based on
Promises as defined by ECMAScript version 6 and many libraries already
implement this interface. For the rest, existing callback-based
functionality can be converted to Promises using `promisify.

Here's an example to give you an idea:

&   require: request
    g = promisify(request.get)
    async getXKCD(n = 0) =
       response = await g('http://xkcd.com/info.{n}.json')
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
thinking about it):

&  repeat(String? thing or Array! thing, Number? match) =
      0 -> {}
      n -> thing ++ repeat(thing, n - 1)
   
   repeat("hello", 4)      ==> "hellohellohellohello"
   repeat({1, 2}, 2)       ==> {1, 2, 1, 2}
   repeat(6, 3)            ==> {6, 6, 6}
   repeat("apple", "pie")  ==> ERROR

More exhaustive documentation can be found
[here @@@ doc.html#patternmatching].


== Macro system




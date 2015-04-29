
meta ::
   title = Earl Grey documentation
   author = Olivier Breuleux
   summary =
      Documentation of the Earl Grey language.
   template = twocol

div#toc %
  js :: document.getElementById("doc").className = "navlink curnav"
  toc::below
div#main % [

= Basic syntax


== Comments

Comments must be prefixed with two semicolons and go until the end of
the line.

&   ;; This is a comment.


== Blocks

Indent groups statements in Earl Grey. Alternatively, you can use
square `[[]] brackets:

&   hello
       superb
       world

is equivalent to:

&   hello[superb; world]

It is recommended to use indent to denote blocks, so you will not use
square brackets much in practice. Just be aware that the expression
`[[a]] is equivalent to plain `a, and `[[a, b, c]] is going to return
`c (commas and semi-colons are equivalent in EG).

Save for indented blocks, _all line breaks are semi-colons in Earl
Grey. There is _no implicit line continuation. This being said, you
can break a statement over multiple lines by _prefixing continuating
lines with `[\ ]:

&   a
    \ + b
    \ + c

is equivalent to:

&   a + b + c

Be aware that indent isn't going to work for this: replacing the
backslashes with indent will yield `a[+ b; + c].


== Variables

Variables can be declared as mutable or immutable

&   var x = 123        ;; mutable variable
    let x = "hello"    ;; const variable (immutable)

Hyphens are allowed inside variable names. This is valid:

&   var my-variable = 1234

Scoping is lexical: variables declared in a block are only valid in
that block.

If you simply write:

&   x = {1, 2, 3}

Then what happens depends on whether a variable called `x already
exists in scope.

* It exists and is mutable: the variable is modified.
* It exists and is immutable: compile time error.
* It does not exist: it is declared in the current block as _immutable.

This means that most of the time you can declare variables without the
`let keyword, assuming they don't already exist. You only need `let
if you are shadowing an existing variable. I recommend only using
`var if absolutely necessary -- if you follow that advice it is
basically impossible to make scoping errors.

Note that the `var and `let keywords can be used inside
patterns. For instance:

&   {var {x, y}, let z} = {{1, 2}, 3}   ;; x and y are mutable; z isn't

The __[`where] statement is another alternative to declare variables
local to single expressions. Here's a funny example:

&   x + y where
       x = 100
       y = 200
       x + y = x - y
    ;; ==> -100

(Yes, you can do that)

=== Global variables

Global variables need to be declared to be accessible:

&   globals:
       document, google, React


== Literals and data structures

=== Strings

&   "this is a string"
    "Escape \" with a backslash"
    'single-quoted strings support interpolation'
    'there are {n} little piggies' where n = 3
    """this is a
       "long"
       multiline string"""
    .this_is_also_a_string

=== Numbers

&   123                ;; decimal
    16rDEADBEEF        ;; hex
    2r100101011.101    ;; binary

=== Arrays and objects

Both arrays and object literals are defined with curly braces:

&   {1, 2, 3}            ;; an array
    {a = 1, b = 2}       ;; an object
    {"a" => 1, "b" => 2} ;; the same object

You can also "mix" the notations:

&   {1, 2, a = 3, b = 4} ;; an array with fields named a and b


== Functions

There are several different, but equivalent notations to call functions:

&   func(arg1, arg2)           ;; the usual notation
    func{arg1, arg2}           ;; curly bracket notation
    func(arg1) with arg2       ;; with-notation
    func(___, arg2) with arg1  ;; with-notation (using placeholder)
    func with arg              ;; with-notation (single argument)

The with-notation can be used to increase readability. For instance:

&   {1, 2, 3}.map(x -> x * x)
    <=>
    {1, 2, 3}.map with x ->
       x * x

The gains are most visible when the body of the function is large.


=== Splicing

You can apply a function to a list of arguments using the `[*]
splicing operator, `[[]], or simple juxtaposition:

&   args = {1, 2, 3}
    func(*args) <=> func[args] <=> func args

EG considers function application to be a special case of indexing
where the index is a list of arguments, hence why the above works.

=== Declaring functions

&   square(x) =
       x * x

    square = x -> x * x

The notation also works inside an object:

&   {a = 10, mul(b) = this.a * b}.mul(20)
    ;; => 200

There is no need to `return from a function (although you can). The
last evaluated expression is used as the return value.

=== (Re-)declaring operators

Operator applications in EG, such as `[a + b], desugar to the function
call `[+]{a, b}. You can thus redefine almost any operator locally:

&   bizarro(a, b) =
       let x + y = outer{+}{x, y}
       let x - y = outer{-}{x, y}
       a + b - c
    bizarro(10, 20, 10)  ;; ==> 0

.note %
  * `let must be used in order to shadow the existing bindings.
  * `outer returns the previous binding of a variable, which is
    necessary above to avoid unwanted mutual recursion.
  * The curly braces notation must be used because `outer, `[+] and `[-]
    are macros and `() cannot be used to provide macro arguments.


== `if and `while


__[If statements] are written as they are in Python:

&   if x < 0:
       do_something()
    elif x > 0:
       do_something_else()
    else:
       flail_incoherently()

`if can also be written as an expression. It's not a ternary operator
because I honestly don't think it's worth tweaking syntax for:

&   if{x < 0, 0, x}


__[While statements], again, look like Python's:

&   var i = 10
    while i > 0:
       print i
       i--

If you want to give a label to a `while loop (or to _any loop), you
need to use `while.label, just like this:

&   var i = 0
    while.outer true:
       var j = 0
       while.inner true:
          if i * j == 40:
             break outer  ;; this will break out of both while loops!
          j++
       i++


== Looping

EG defines `for statements that are a cross between JavaScript's
semantics and Python's syntax, which means that it comes in three
flavors:

&   for (var i = 0; i < 10; i++):
       print i

    for key in object:
       print key

    for element of iterable:
       print element

They work like you'd expect. I'm telling you about them because you
are free to use what you see fit, but in my opinion, __[`for should
not be used]:

=== `each

Instead, EG's __[`each] operator should be used, either as a
statement:

&   1..10 each i -> print i * i

or as an expression:

&   squares = 1..10 each i -> i * i

`each in a statement position compiles to a straight `for..of loop, so
it's no less efficient. In expression position, it acts as an array
comprehension.

Besides doubling up as array comprehensions, what makes `each a useful
looping method is that it makes use of EG's built-in pattern matcher:

&   {13, "car", "tramway", 517} each
       Number? n -> n + 1
       String? s -> s + "s"
       else -> throw E.unknown("I don't know.")
    ;; ==> {14, "cars", "tramways", 518}

You can also use `when to filter data:

&   1..10 each i when i mod 2 == 0 -> i
    ;; ==> {2, 4, 6, 8, 10}

`break and `continue work with `each:

* `break stops the comprehension. It is the only way to halt
  iteration before the end of the sequence.
* `continue starts the next iteration but without accumulating a
  value. You can use it as an alternative way to filter.

&     1..100 each i ->
         if i > 10:
            break
         elif i mod 2 == 0:
            i
         else:
            continue
      ;; ==> {2, 4, 6, 8, 10}

When using pattern matching with `each, EG will throw an exception if
a value does not match any of the patterns _unless the last pattern
contains a `when` clause. In other words:

&   {1, "x", 2, 3} each
       Number? n -> n            ;; ERROR! "x" does not match

But these expressions will not throw exceptions:

&   {1, "x", 2, 3} each
       n when Number? n -> n     ;; ==> {1, 2, 3}

    {{1}, {2, 3}, {4}, {5, 6}} each
       {x, y} when true -> x + y ;; ==> {5, 11}

    {{1}, {2, 3}, {4}, {5, 6}} each
       {x, y} -> x + y
       else -> continue          ;; ==> {5, 11}

The first form is recommended if it is easy to express the condition
as an expression. However, some filters are best expressed by
patterns, in which case the third form would be preferred (because it
is less confusing -- you can use the second form if you insist on
writing a one-liner, though).

`each is _eager: it will iterate over all elements and execute the
payload on each, returning an array. The _lazy version of `each is the
`each* operator.


= Pattern matching

The `match operator feeds an input into a series of "clauses" and
enters the body of the first matching clause. In a clause, one can
check the type of a value, cast or transform it, deconstruct an array
into elements and bind them to variables, and more:

&   match command:
       {"move", Number! dx, Number! dy} ->
          ;; Isn't this nicer than calling parseFloat manually?
          this.x += dx
          this.y += dy
       {"rest", Number! nhours} ->
          this.hp += nhours
       {"attack", Grue?} ->
          ;; We can special-case commands but they have to come before
          ;; the generic version.
          this.die_horribly()
       {"attack", enemy} ->
          enemy.hp -= this.attack
          this.hp -= enemy.attack

A pattern can also be found on the left side of a declaration or
assignment, for example:

&   {String? x, Number? y} = {"apple", 3.14159}


=== Checkers

A __checker verifies that the thing to match satisfies some predicate,
for instance that it is of a certain type.

&   Number? n = 123     ;; OK
    Number? n = "hello" ;; ERROR


=== Projectors

A __projector transforms the thing to match, for instance it casts
it to a certain type or applies some kind of transformation. Further
pattern matching can be applied on the transformed value.

&   Number! n = "123"          ;; n is the number 123
    Array! a = 5               ;; a is the array {5}
    Array! {Number! a} = "10"  ;; a is the number 10


=== Destructuring

An array of patterns matches an array of the same length, and then
tries to match each value with the corresponding pattern:

&   {x, y, z} = {1, 2, 3}      ;; x is 1, y is 2, z is 3
    {x, y, z} = {1, 2}         ;; ERROR
    {x, {y, z}} = {1, 2, 3}    ;; ERROR

The `[*] splicing operator matches any number of elements:

&   {x, *y, z} = {1, 2, 3, 4, 5}   ;; x is 1, y is {2, 3, 4}, z is 5
    {x, *y, z} = {1, 2}            ;; x is 1, y is {}, z is 2

You can assign a default value to a pattern in case it is missing.

&   {x, y, z = "absent"} = {1, 2}  ;; x is 1, y is 2, z is "absent"

This also works to define default values for arguments in
functions. Note that the default value will be recomputed every time
it is needed (or not at all, if it is unneeded). For example:

&   f(x = [print "missing"; 0]) = x
    f(55)     ;; ==> returns 55
    f()       ;; ==> prints "missing", and returns 0
    f()       ;; ==> prints "missing" *again*, and returns 0

(remember that `[stmt1; stmt2] executes both statements in sequence
and returns `stmt2. It's not an array).

This means that unlike in Python, if you define an empty array `{} as
a default value, it will always be a fresh array.


=== `when conditions

The __when operator lets you write arbitrary conditions for a
clause:

&   match command:
       {"move", dx, dy} when dx*dx + dy*dy > threshold ->
          running()
       {"move", dx, dy} ->
          walking()
       ...


=== `or pattern

__or will try to match one of a series of patterns

&   match x:
       ;; match 0, or 1
       0 or 1 -> ...

       ;; match a number or a string
       Number? x or String? x -> ...

       ;; will match {123} or 123, putting 123 in x in both situations
       {x} or x -> ...

__ All sub-patterns must contain the same variables.

Also, patterns are evaluated in the order they are defined, so the
most specific should come first.


=== `and pattern

__and will try to match every pattern (again, in order):

&   Number? n and > 0 = -5     ;; ERROR!

That may not be obvious at first, but `and is useful to create
aliases:

&   {x, y} and z = {1, 2}   ;; x is 1, y is 2, z is {1, 2}

So instead of writing something like `[x = y = 0] to initialize two
variables to zero, you should write `[x and y = 0].


=== Operators

__[Comparison operators] (`[== != < <= > >= in]) can be used partially
(except for `is which has a different meaning). The left hand side is
a pattern, which will only be matched if the predicate on the current
value is true. In other words:

&   n > 0 = 10     ;; n is 10
    n > 0 = -10    ;; ERROR

You can also leave the left hand side empty:

&   compare(value, threshold) =
       match value:
          > threshold -> "above"
          < threshold -> "below"
          == threshold -> "equal"


=== Embedded control structures

The previous idiom of creating a function and matching one argument is
useful enough to have a __shorthand:

&   compare(match value, threshold) =
       > threshold -> "above"
       < threshold -> "below"
       == threshold -> "equal"

Using the word `match in _any pattern will cause the body associated
to the pattern to become a list of clauses, matching in [`match]'s
place. To illustrate:

&   match expr: {x, {y, {z}}} -> ...

can also be written:

&   match expr: {x, match} -> {y, match} -> {z} -> ...

Here's naive fibonacci using the shorthand:

&   fib(match) =
       0 -> 0
       1 -> 1
       n -> fib(n - 1) + fib(n - 2)

You can give a name to the match and it will be bound in all clauses:

&   fib(match n) =
       0 -> 0
       1 -> 1
       else -> fib(n - 1) + fib(n - 2)

The feature also works for rest arguments:

&   concat(*match) =
        {String? a, String? b} -> a + b
        {Array? a, Array? b} -> a ++ b

Other features can be embedded in arguments. For instance, `each can
be used in a pattern:

&   f(each x) = x * x
    f(1..5)                 ;; => {1, 4, 9, 16, 25}

    enhance(match) =
       Number? n -> n * n
       String? s -> s + "s"
       each x -> enhance(x) ;; short for xs -> xs each x -> enhance(x)
    enhance({1, 2, "cake"}) ;; => {1, 4, "cakes"}

`each in this case can be anywhere in a pattern, and multiple `each
found in the same pattern will nest in the order that they are found:

&   f(each x, each y) = x + y
    f({"a", "b"}, {"x", "y"})
    ;; ==> {{"ax", "ay"}, {"bx", "by"}}

`chain can be embedded and you get a nice pipeline going on:

&   capitalizeWords(chain) =
       @trim()
       @split(R" +") each w when w != "" ->
          w[0].toUpperCase() + w.slice(1)
       @join(" ")
    capitalizeWords(" pulp  fiction ")
    ;; => "Pulp Fiction"


=== `is operator

Sometimes you may need or want to give a value to a variable inside a
pattern. You can do this with `is:

&   x and y is 10 = 5                     ;; x is 5, y is 10
    {x, y} or x is 0 and y is 0 = "blah"  ;; x is 0, y is 0

One use case is to remove one level of nesting in the following code:

&   f(match, x) =
       {a, b} ->
          match x:
             ...

The above can be rewritten:

&   f(match, x) =
       {a, b} and match is x ->
          ...

=== Assignment wrappers

The keywords `get, `return, `yield and `await may be used in a
pattern on the left hand side of an assignment. Normally, an
assignment returns the variable it declares, or if there is more than
one variable, an array of the declared variables:

&   x = 4                       ;; ==> 4
    {x, {y, z}} = {1, {2, 3}}   ;; ==> {1, 2, 3}
    {x, _, y}   = {1, 2, 3}     ;; ==> {1, 2}
    {x, String! y} = {1, 2}     ;; ==> {1, "2"}

You can, however, modify this behavior:

&   {x, get, z} = {1, 2, 3}     ;; ==> 2
    {_, return, _} = {1, 2, 3}  ;; immediately returns 2 from the function
    {yield, yield} = {1, 2}     ;; yields 1, then yields 2

Note that it's not particularly useful to declare variables alongside
`return since there's no way to use them after the function returns.

.warning %
  Combining more than one of these in the same pattern is currently a
  bit flaky.



= Asynchronous code

Like ES6, EG has generators. Like ES7 (proposed), it has `async and
`await keywords.

=== Generators

A generator is a function that can produce (`yield) an arbitrary
number of values as they are requested by a consumer. For instance,
this is a generator for the Fibonacci numbers:

&   gen fib() =
       var {a, b} = {0, 1}
       while true:
          yield a
          {a, b} = {b, a + b}

That function is an infinite loop, but at each invocation of `[yield
a], it sends the value of `a to the consumer and stops until the
consumer asks for the next value. The `consume function can be used
to retrieve a certain number of values from the generator:

&   consume(fib(), 10) ;; ==> {0, 1, 1, 2, 3, 5, 8, 13, 21, 34}

`each and `for...of will consume a generator until a `break
statement is encountered. `each* will create a new generator:

&   fibsquared = fib() each* n -> n * n
    consume(fibsquared, 10)
    ;; ==> {0, 1, 1, 4, 9, 25, 64, 169, 441, 1156}

Here the difference between `each and `each* is that `each will
keep accumulating values until it runs out of memory, whereas `each*
is lazy just like `fib.


=== Promises and async/await

Promises and generators are ES6's answer to callback hell and EG
supports them. `async and `await make them even easier to use:

&   require: fs
    readFile = promisify(fs.readFile)

    async cat(*files) =
       var rval = ""
       files each file ->
          rval += await readFile(file, .utf8)
       print rval

    async:
       cat("file1", "file2", "file3")
    ;; returns immediately

Here's how it works:

* `[require: fs] fetches node.js's filesystem module

* `promisify(fs.readFile) changes [`fs.readFile]'s callback-based
  interface to a Promise-baed interface, which is necessary to work
  with async.

  `promisify should work on any function that implements node's callback
  interface, i.e. where the last argument has the form `[{error, result} -> ...]

* `[await readFile(file, .utf8)] reads the file _asynchronously, in
  the background. At that moment, the execution of `cat stops and
  other tasks can be executed while waiting for the file to be read.

* Once the file is read, the result is given back to `cat. It keeps
  going until all the files have been read, and then it prints them.

* If `readFile calls back with an error, an exception will be raised.
  However, when an async function is called without a corresponding
  `await, the error will be ignored. The `[async:] block mitigates
  this issue by wrapping the async call, catching the error, and
  logging it.


= Module system

`require may be used to import functionality from other
modules. `provide may be used to export functionality.

=== `require

Ideally, all of a module's imports should be in a single `require
block.

&   require:
       fs, path
       react as React
       something(1234)
       "./mymodule" ->
          some-function, other-function as blah

This is roughly equivalent to the following JavaScript:

javascript &
    var fs           = require("fs")
      , path         = require("path")
      , React        = require("react")
      , something    = require("something")(1234)
      , _temp        = require("./mymodule")
      , someFunction = _temp.someFunction
      , blah         = _temp.otherFunction;

=== `provide

`provide fills the module's exports:

&   provide:
       fn1, fn2
       fn3 as xyz

It is recommended to put it at the beginning of the file so that it is
clear what symbols the module provides.

=== `inject

TODO

=== `require-macros

`require-macros works like `require, but the imported symbols are
defined as macros.

`earl currently does not take into account the dependencies listed by
`require-macros when deciding whether to recompile a file or not. If
those dependencies change, dependents may not be recompiled, so you
will need to `touch them or use the `[-r] flag to force them to be.


= Document-building syntax

The `[%] operator can be used to build structured "documents". It
creates an instance of the `ENode data structure, which contains a
set of tags and attributes along with a list of children.

`ENode instances mostly just hold structure and are meant to be
converted into something else, for instance HTML:


&   node =
       div#main %
          "Some text"
          strong % 1234
          a.large.red %
             href = "http://example.com"
             "stuff"

    node.toHTML{}

Would produce:

html &
    <div id="main">
      Some text
      <strong>1234</strong>
      <a class="large blue" href="http://example.com">stuff</a>
    </div>



= Macros

I am only going to present part of the macro system here. The complete
system is much more powerful, but I haven't yet figured out the best
external API.

Macros in EG cannot extend the parser; however, EG's syntax is
flexible enough that there isn't much of a need to extend it.

=== Invariants

A lot of EG's syntax is sugar. It is simpler than it looks:

&   a: b          <=> a{b}
    a b: c        <=> a{b, c}
    a b           <=> a[b]

So for instance, the expression `[if x < y: z] actually has the same
AST as `if{x < y, z}. For that matter, `if[{x < y, z}] is also
equivalent, and `[return x + y] yields the same AST as `return[x + y].

=== quote

EG code can be "quoted" by putting it inside backticks:

&   `a + 2`
    ;; => the AST of "a + 2"
    ;; => #send{#symbol{"+"}, #data{#symbol{"a"}, #value{2}}}

You can "unquote" with the caret operators. Use `[^] to insert a bit of
AST or `[^=] to insert a value.

&   apb = `a * b`
    two = 2
    `^=two * ^apb` == `2 * (a + b)`

Together these features let you pattern match on code:

&   match `a + b * c`:
       `^x + ^y` -> "addition"
       `^x * ^y` -> "multiplication"
       `^f ^arg` -> "application"

Be careful about the order of patterns. The "application" pattern may
not look like it, but it will match the expression `[a + b] with `[+] in
`f and `{a, b} in `arg (because `[a + b] <=> `[[+] {a, b}]).


=== Examples

__unless can be defined as a counterpart to `if:

&   macro unless(`{^cond, ^body}`):
       `if not ^cond: ^body`

    unless(1 == 2, print "all is well")  ;; prints "all is well"

    unless 1 == 2:
       print "all is well"               ;; same as above

Here is a simple macro for __assert:

&   macro assert(cond):
       code = @gettext(cond)
       `if{cond, true, throw E.assert("Assertion failed: " + ^code)}`

    assert 1 == 2
    ;; => throws E.assert("Assertion failed: 1 == 2")

]

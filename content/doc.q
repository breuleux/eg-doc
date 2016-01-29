
template :: default

meta ::
  title = Earl Grey documentation
  author = Olivier Breuleux
  summary =
    Documentation of the Earl Grey language.

;; resources ::
  toc-scroll.js

store sidebar ::
  toc::

js :: document.getElementById("use").className = "navlink curnav dropdown"

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
    let y = "hello"    ;; const variable (immutable)

Hyphens are allowed inside variable names. This is valid:

&   var my-variable = 1234

Scoping is lexical: variables declared in a block are only valid in
that block.

If you simply write:

&   x = {1, 2, 3}

Then what happens depends on whether a variable called `x already
exists in scope.

* It __exists and is __mutable: the variable is modified.
* It __exists and is __immutable: compile time error.
* It __[does not exist]: it is declared in the current block as _immutable.

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

Use double quotes:

&   "this is a string"
    "Escape \" with a backslash"
    'single-quoted strings support interpolation'
    """this is a
       "long"
       multiline string"""

The prefix dot operator creates strings as well, but only if the
string represents a valid variable name:

&   .hello == "hello"

If there are dashes in a dot-string, it is converted to camelCase:

&   .hello-world == "helloWorld"

This means that if you write a method call with dashes, for instance
`document.get-element-by-id("some-id"), it will compile to
`document.getElementById("some-id"). You have the choice of either
notation.


=== Interpolated strings

Single quotes are interpolated.

&   n = 3
    print 'there are {n} little piggies'
    ;; ==> there are 3 little piggies

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

__[Empty data structures] are denoted as follows:

&   empty-array  = {}
    empty-object = {=}


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

div.note %
  * `let must be used in order to shadow the existing bindings.
  * `outer returns the previous binding of a variable, which is
    necessary above to avoid unwanted mutual recursion.
  * The curly braces notation must be used because `outer, `[+] and `[-]
    are macros and `() cannot be used to provide macro arguments.


== if and while


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
They work like you'd expect (with one little gotcha*). I'm telling you
about them because you are free to use what you see fit, but in my
opinion, __[`for should not be used]:

div.warning %
  *Earl Grey parses commas and semicolons as essentially the same, so
  this will not work:

  & for (var i = 0, var j = 0; i < 10; i++, j++):
       print i + j

  EG will think the first comma is a semicolon. Here's a valid
  alternative:

  & for (var {i, j} = {0, 0}; i < 10; (i++; j++)):
       print i + j


=== each

EG's __[`each] operator should be used instead of `for, either as a
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
contains a `when clause. In other words:

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
          this.die-horribly()
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

__Important: Projectors are applied __[left to right]. This could be a
bit counter-intuitive sometimes, so let me give you clear examples
that you can use as reference:

&   add-one! multiply-by-two! x = 10   ;; x is ((10 + 1) * 2) = 22
    multiply-by-two! add-one! x = 10   ;; x is ((10 * 2) + 1) = 21

Projectors also work on functions, where they are quite useful. For
example:

&   curry! f(x, y) = x + y

They can also save you some typing if you use them on function
arguments. If you wanted to implement a `save-all function that works
on an array of files, but also on a single file, you could write:

&   save-all(Array! files) =
       files each file -> file.save()

instead of, say:

&   save-all(var files) =
       if not Array? files:
          files = {files}
       files each file -> file.save()


=== Inline projectors

The `[>>] operator, in a pattern, transforms the match result. That
can be useful sometimes, usually in argument lists or nested patterns
where you can't simply apply the transform on the expression to the
right of the equal sign.

&   x >> ((x + 1) * 2) = 10    ;; x is 22
    x >> {x, x} = 6            ;; x is {6, 6}
    x >> x.trim() = "  xyz "   ;; x is "xyz"


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


=== Destructuring objects

The `[=>] operator inside patterns lets you extract object fields.

`[=> xyz] will extract the field named `xyz into the variable `xyz:

&   {=> x, => y} = {x = 1, y = 2}        ;; x is 1, y is 2

`[xyz => abc] will extract the field named `xyz into the variable `abc:

&   {x => a, y => b} = {x = 1, y = 2}    ;; a is 1, b is 2

The right hand side can be a pattern. If there is no left hand side,
but that the right hand side defines a single variable, then the left
hand side is set to the name of that sole variable:

&   {x => {a, b}, => {y}} = {x = {1, 2}, y = {3}} ;; a is 1, b is 2, y is 3

You don't have to extract all fields:

&   {=> x} = {x = 1, y = 2}              ;; x is 1, the y field is ignored

The unquote operator `[^] can be used to match a dynamic key if needed:

&   key = "x"
    {^key => y} = {x = 66}               ;; y is 66



=== when

The __when operator lets you write arbitrary conditions for a
clause:

&   match command:
       {"move", dx, dy} when dx*dx + dy*dy > threshold ->
          running()
       {"move", dx, dy} ->
          walking()
       ...


=== or

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


=== and

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
       (each x) -> enhance(x) ;; short for xs -> xs each x -> enhance(x)
    enhance({1, 2, "cake"}) ;; => {1, 4, "cakes"}

.warning %
  The parentheses around `(each x) are needed above, otherwise the
  clause is parsed like `[each (x -> enhance(x))], which is not legal
  (at least not yet).

`each in this case can be anywhere in a pattern, and multiple `each
found in the same pattern will nest in the order that they are found:

&   f(each x, each y) = x + y
    f({"a", "b"}, {"x", "y"})
    ;; ==> {{"ax", "ay"}, {"bx", "by"}}

`chain can be embedded and you get a nice pipeline going on:

&   capitalize-words(chain) =
       @trim()
       @split(R" +") each w when w != "" ->
          w[0].to-upper-case() + w.slice(1)
       @join(" ")
    capitalize-words(" pulp  fiction ")
    ;; => "Pulp Fiction"


=== is

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

The keywords `expr-value, `return, `yield and `await may be used in a
pattern on the left hand side of an assignment. Normally, an
assignment returns the variable it declares, or if there is more than
one variable, an array of the declared variables:

&   x = 4                           ;; ==> 4
    {x, {y, z}} = {1, {2, 3}}       ;; ==> {1, 2, 3}
    {x, _, y}   = {1, 2, 3}         ;; ==> {1, 2}
    {x, String! y} = {1, 2}         ;; ==> {1, "2"}

You can, however, modify this behavior:

&   {x, expr-value, z} = {1, 2, 3}  ;; ==> 2
    {_, return, _} = {1, 2, 3}      ;; immediately returns 2 from the function
    {yield, yield} = {1, 2}         ;; yields 1, then yields 2

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
  interface to a Promise-based interface, which is necessary to work
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


= Classes

The `class keyword can be used to declare a new class.

Each method has a reference to the object in the variable `self and as
the `[@] operator. Here's a simple class to get you started:

=== Defining

&  class Person:
      constructor(name, age) =
         @name = name
         @age = age
      advance-inexorably-towards-death(n > 0 = 1) =
         @age += n
      say-name() =
         print 'Hello! My name is {@name}!'

Instead of setting values in the constructor manually as the above
you can also use the following shortcut:

&  class Person:
      constructor(@name, @age) =
         ;; pass is a placeholder keyword; like in Python it just means "do nothing"
         pass

This works for all methods, not just the constructor.


=== Instantiating

Instantiating a class can be done with the `new keyword, or not. It
doesn't matter.

&  alice = new Person("alice", 25)
   bob = Person("bob", 44)
   bob.advance-inexorably-towards-death()

div.note %
  The `new keyword may be needed to instantiate some classes in third
  party packages, check their documentation to be sure.


=== Subclassing

The `[<] operator is used to define the superclass of a new class.

&  class Baker < Person:
      bake(n) =
         print '{@name} is baking {n} cake{if{n > 1, "s", ""}}!'

   carmen = Baker("carmen", 30)
   carmen.bake(1)
   carmen.advance-inexorably-towards-death()
   carmen.bake(20)

There is no `super keyword at the moment. I'll fix that at some point.


=== Static methods

Define static methods for a class using a `[static:] block:

&  class Person:
      static:
         make-twins(name1, name2, age) =
            {Person(name1, age), Person(name2, age)}
      constructor(@name, @age) =
         pass
      ...


=== Special methods

There are a few interesting special methods you can define on a class
to customize its behavior:

* `Symbol.iterator is used by `each and `for..of to iterate over your
  object. You must return a generator (use `gen and `yield, see
  below).

* `Symbol.check is consulted by the `[?] operator.

* `Symbol.project is consulted by the `[!] operator.

* `Symbol.contains is consulted by the `[in] operator.

Under ES6 semantics, these methods are not strings, but special
symbols. You will therefore need the unquote operator `[^] to set
them, but it's easy enough:


&  class Multiples:
      constructor(@n) =
         pass

      ;; Iterate through all multiples of @n using a generator
      gen (^Symbol.iterator)() =
         ;; This is an infinite iterator. Be careful.
         0.. each i ->
            yield i * @n

      ;; Check that a number is a multiple of @n
      (^Symbol.check)(n) =
         Number? n and n mod @n == 0

      ;; Round down n to a multiple of @n
      (^Symbol.project)(n) =
         n - (n mod @n)

      ;; We'll define this the same as Symbol.check
      (^Symbol.contains)(n) = (@)? n

   mul3 = Multiples(3)

   ;; print all multiples of 3 no greater than 100
   mul3 each
      > 100 -> break
      n -> print n

   ;; this will fail because 25 is not a multiple of 3
   mul3? x = 25

   ;; this will set y to 24
   mul3! y = 25

   ;; the following is true
   3 in mul3

div.note %
  Don't forget the parentheses around `(^Symbol.iterator) and friends.
  Otherwise you will get an error like "symbol/string is not a function".
  That's normal because `[^] means to set the key corresponding to the
  value of an expression and without the parentheses it'll think the key
  is the value of the whole expression `Symbol.iterator() instead of just
  `Symbol.iterator.


=== TODO

There are some missing features I'll add at some point, tell me if you
need them.

* `super keyword
* getter/setters




= Miscellaneous

=== chain

`chain is how you chain methods in EG.

The body of `chain should contain a sequence of statements. The return
value of each statement is tied to the `[@] operator in the next.

Here's an example:

&   chain "hello":
       ;; @ is "hello"
       @replace("o", "")
       ;; @ is "hell"
       {@, "is", "freezing"}
       ;; @ is {"hell", "is", "freezing"}
       @join(" ")
    ;; ==> "hell is freezing"


=== Regular expressions

Regular expressions are written with the `R prefix, for instance,
`R"\d+(\.\d*)?"

They can be used as checkers or projectors. For example:

&   mangle(match email) =

       ;; regexp! transforms the input into an array of match groups
       ;; (the first is always the whole match)
       R"^([a-z.]+)@([a-z.]+)$"! {_, name, host} ->
          '{name} AT {host}'

       ;; regexp? will just test if the regexp matches, but it won't
       ;; transform the input
       R"@"? ->
          "It looks like an email but I'm too daft to parse it."

       else ->
          "This is not an email at all!"


=== Errors and exceptions

* `throw is used to throw an exception
* `try and `catch are used to catch an exception
* `finally is used for cleanup
* `E is used to build customized exceptions

&  try:
      throw E.test.my-error("This is my error.")
   catch TypeError? e:
      print "There was a type error."
   catch E.my-error? e:
      print "My error!"
   catch e:
      print "Some other error."
   finally:
      print "We are done."



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

    require: /html
    html(node)

Would produce:

html &
    <div id="main">
      Some text
      <strong>1234</strong>
      <a class="large blue" href="http://example.com">stuff</a>
    </div>


= Macros

There are two means of defining macros in EG:

* `inline-macro defines a macro for use in the current file and the
  current scope. They cannot be exported from the module at the
  moment.

* `macro defines an exportable macro. It cannot be used in the file or
  scope in which it is defined, but it can be imported with
  `require-macros and used from other modules.

I wouldn't say it's the best setup, but it's still fairly good, and
the one that exists at the moment.

Macros in EG cannot extend the parser; however, EG's syntax is
flexible enough that there isn't much of a need to extend it.

First, though, some basics must be laid out:

=== Invariants

A lot of EG's syntax is sugar. Here's what you should know:

* __[Parenthesis elimination]: parentheses are sugar for the other two
  bracket types:
  bash & a(b)          <=> a{b}
         a(b, c)       <=> a{b, c}
         (a)           <=> [a]       <=> a
         (a, b)        <=> [a, b]

* __[Operator rules]: operator applications desugar to function/macro
  calls. If the operator is prefix or postfix, one of the arguments
  will be void. Except for commas, colons and `with, _all operators
  undergo that simplification, including core ones like `[=] or `[->]:
  bash & a + b         <=> [+]{a, b}
         + a           <=> [+]{[], a}
         a +           <=> [+]{a, []}

* __[Colon rules]:
  bash & a: b          <=> a{b}
         a b: c        <=> a{b, c}

* __[Juxtaposition rule]:
  bash & a[b]           <=> a b

So for instance:

& if x < y: z   <=> if{[<]{x, y}, z}
  return x + y  <=> return[[+]{x, y}]
  var x = 1234  <=> [=]{var[x], 1234}


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
not look like it, but it would match the expression `[a + b] with `[+]
in `f and `{a, b} in `arg (because `[a + b] <=> `[[+] {a, b}]).


=== inline-macro

The syntax goes like this:

&   inline-macro macro-name(expression):
       build-new-expression(expression)

The expression is the AST of the argument given to the macro call and
it is determined like this:

+ Situation               + Value of expression
| `macro-name(x)          | `[`{x}`]
| `macro-name{x}          | `[`{x}`]
| `macro-name(x, y)       | `[`{x, y}`]
| `macro-name[x]          | `[`x`]
| `[macro-name x]         | `[`x`]
| `macro-name[x, y]       | `[`[x, y]`]
| `[macro-name: x]        | `[`{x}`]
| `[macro-name x: y]      | `[`{x, y}`]
| `[macro-name x: y, z]   | `[`{x, [y, z]}`]
| `macro-name             | `[#void{}]

The last situation is only triggered if the expander encounters
`[macro-name] alone and with _no arguments. Note that the expression
isn't inside backticks, you have to match `[#void{}], literally.

__Example: __unless as a counterpart to `if:

&   inline-macro unless(`{^cond, ^body}`):
       `if not ^cond: ^body`

    unless(1 == 2, print "all is well")  ;; prints "all is well"

    unless 1 == 2:
       print "all is well"               ;; same as above

Here is a simple macro for __assert:

&   inline-macro assert(cond):
       code = @raw(cond)
       `if{cond, true, throw E.assert("Assertion failed: " + ^code)}`

    assert 1 == 2
    ;; => throws E.assert("Assertion failed: 1 == 2")


=== macro

Unlike `inline-macro, `macro is built to create exportable macros. The
basic syntax is as follows:

&   macro macro-name(expression) =
       build-new-expression(expression)

For example:

`unless.eg:

&   provide: unless
    macro unless(`{^cond, ^body}`):
       `if not ^cond: ^body`

`script.eg:

&   require-macros: "./unless" -> unless
    unless 1 == 2:
       print "all is well"

==== Dependencies

Some macros may need to produce code that refers to particular
libraries, data structures, and so on. For this purpose it is possible
to declare a list of dependencies for a macro:

&   macro{dependencies, ...} macro-name(expression) =
       build-new-expression(expression)

Each listed dependency is then associated to a special symbol in
`[@deps], and that symbol can be inserted in the generated code.

Here's an example:

`uniq.eg:

&   provide: unique-id
    var id = 0
    next-id{} = id++
    macro{next-id} unique-id(#void{}) =
       let next-id-sym = @deps.next-id
       `[^next-id-sym]{}`

`script.eg:

&   require-macros: "./uniq" -> unique-id
    print unique-id    ;; 0
    print unique-id    ;; 1
    print unique-id    ;; 2
    ...

The unexported function `next-id in `uniq.eg is declared as a
dependency by `unique-id, which can generate code using it. Behind the
scenes, Earl Grey exports `next-id under a mangled name and
automatically imports it along with `unique-id. In other words, the
generated code will look a bit like this:

&   require-macros: "./uniq" -> unique-id
    require: "./uniq" -> next-id$0
    print next-id$0{}
    print next-id$0{}
    print next-id$0{}
    ...

=== Hygiene

__Hygiene is an important property of macro systems: the goal is to
keep macros well-behaved by making sure that the variables defined in
user code do not leak into macro-generated code, and vice versa. For
instance, a macro generating an `if statement ought not to stop
working if, for some reason, the user rebinds the `if variable.

EG tags every node output by the parser with an `env field. Two
symbols refer to the same variable if and only if looking up their
names in their respective environments in their respective scopes
yields the same reference for both. By default, code constructed using
quote has no `env, but when it is returned to the macro expander,
untagged nodes are tagged with a fresh environment that looks up
bindings at the definition site. This protects the user's bindings
from interfering with the macro's, and vice versa.

By extracting the environment of its form or argument and tagging
generated code snippets with it, a macro can "violate" hygiene. This
lets it intentionally define variables for use inside the macro. This
is typically done with the `[@env.mark] method. Here is an example:

==== Capturing names

&    inline-macro func(body):
        ;; Create a function with a single argument named $
        dolla = @env.mark(`$`)
        `^dolla -> ^body`

     add10 = func $ + 10
     add10(91)        ;; ==> 101

     first4 = func $.substring(0, 4)
     first4("hello")  ;; ==> "hell"

What we want to do is simple: we want to let the body of `func refer
to its argument with `[$]. If we did this naively, e.g. by returning
`[`$ -> ^body`], it would not work, because EG will think that the
argument named `[$] and the occurrences of `[$] in the body refer to
_[different variables]. This is usually a good thing, but now we want
to defeat it.

__[`[@env]] is the environment in which the call to the `func
statement was made (it could be user code, or it could be another
macro). `[@env.mark{`$`}] will therefore "mark" a `[$] symbol as
belonging to that same environment, and we save that marked symbol in
the `dolla variable. All we have to do, then, is to use this marked
variable to declare the argument.

div.note %
  You can also get an `env from `body or any other node (e.g. we could
  have called `[body.env.mark(`$`)]). This will only make a difference
  if they come from different environments, for instance if another
  macro was to build the expression `[`func ^x`]. __[It is usually
  safest] to use `[@env] because it refers to the macro call itself,
  so unintended interference is rather unlikely.

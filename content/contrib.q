
template :: default

meta ::
  title = Contributing to Earl Grey
  author = Olivier Breuleux
  summary =
    Contributing to Earl Grey

nav side ::
  toc::

js :: document.getElementById("use").className = "navlink curnav dropdown"

css ::
  code.hlinline {
    background: #f5f5ec;
    padding: 3px;
  }


[\label _@@ \url] => __[{label} @@ {url}]
[@@! \project] => {project} _@@ https://github.com/breuleux/{project}
;; [\maybe\text @@@ \maybe\path] => {text}@@{siteroot}{path}


= Contribute to Earl Grey

Here is an (incomplete) list of ways you can contribute to the
development and tooling of Earl Grey, and information about how to do
it.

Earl Grey's source code is [available on Github]_@@https://github.com/breuleux/earl-grey.

* Report an issue @@ https://github.com/breuleux/earl-grey/issues

It is written in Earl Grey. Of course. Unfortunately, it is not yet
very well documented, but I will get around to it (I will get around
to it faster if you show interest).

* Join the `[#earlgrey] channel on FreeNode.
* Join the gitter chat!

  {gitter}

gitter =>
  html :: <a href="https://gitter.im/breuleux/earl-grey?utm_source=badge&amp;utm_medium=badge&amp;utm_campaign=pr-badge&amp;utm_content=badge"><img src="https://camo.githubusercontent.com/da2edb525cde1455a622c58c0effc3a90b9a181c/68747470733a2f2f6261646765732e6769747465722e696d2f4a6f696e253230436861742e737667" alt="Join the chat at https://gitter.im/breuleux/earl-grey" data-canonical-src="https://badges.gitter.im/Join%20Chat.svg" style="max-width:100%;"></a>


= Syntax highlighting

Okay. Let's say you want to highlight Earl Grey.

First of all, there are really only two criteria for good syntax
highlighting (at least from my understanding):

# Make it look _good.
# Make the important parts of the code _[stand out].

Now, Earl Grey is a bit unique because it has a macro system, and this
macro system lets you define your own shiny new control structures,
for example `describe and `it from @@!earl-mocha:

&   describe "MyClass":
       it "my-method":
          ...

Or `task from @@!earl-gulp:

&   task my-task < task-it-depends-on:
       ...

Wouldn't it be nice if a syntax highlighter could pick up on `describe
and `it and `task and make them stand out? Good news: this can be
done. It requires some lookahead and lookbehind, so it may be a bit
tricky to do it properly in some editors/libraries, but it's really
great if you can get it working.

Here's how it works.

Given that:

* A "symbol" is any sequence of characters that denotes a symbol in
  EG: `xyz, `var, `my-symbol, and so on, but __not the following
  symbols: `[as and each each in is mod not of or when where with]. These
  symbols are operators and should be highlighted separately.

* `[and= or= mod= each= each* each*=] are also operators
  (_technically, so are `[is*&], `[not***], and other sequences of an
  operator word and operator characters, but you'll be forgiven if you
  ignore this detail).

* `key is the symbol that should be highlighted as a keyword.

What we want to highlight are these:

* __[Control forms]:
  * __[`[key expr1: expr2]], for example `[if x < y: x + y]
  * __[`[key: expr]], for example `[require: package]
* __[Call form]:
  * __[`[key expr]], for example `[return x + y] or `[print "hello"]

Now, the basic idea is this:

* Highlight __[`[key token]] when:
  * There is whitespace between `key and `token
  * `token is a symbol, a string, a number, or is an operator followed
    by no whitespace. In other words, `[a + b] does not highlight `a,
    but `[a +b] does.
  * Notice that this rule will also highlight [` key expr1: expr],
    so we get that for free! Hurray!

* Highlight __[`[key:]] when:
  * `key is _[not preceded] by an operator.
  * Unless the operator is a "low-priority" operator from this list:
    `[= -> => % each each* where with , ;], as well as all the assignment
    operators `[+= -= or= mod= ...]

* Highlight these common keywords:
  __ `[await break chain continue else expr-value match return yield].
  These keywords are often found in isolation, for example `break in
  `[while true: break]. For clarity they should still be highlighted
  as keywords; just add them manually.


== Keyword highlighting test

You should highlight `key like in the following block of code, but
avoid highlighting `nokey.

&  key x
   key +x; key @x; key .x; key "x"; key 0
   key (x); key [x]; key {x}
   nokey.x; nokey{x}

   key x + y
   key key x
   x + key y
   nokey + x

   key: x
   key nokey: y
   key x > nokey: z
   x + key nokey: z

   x + nokey: y
   x mod nokey: y
   x = key: y
   x each key: y

   nokey mod: y      ;; do not highlight nokey, because mod is an operator

   ;; Highlight all of these:
   await; break; chain; continue; else; expr-value; match; return; yield

Just for the record, there is a small bug in the highlighter I use on
this page that makes it so that the `mod operator above isn't bolded,
even though it should be. This is caused by some unfortunate
interference between some of my rules. Pretend they are bolded.


== Edge-case highlighting test

Dashes in variable names can complicate highlighting a bit, so here
are tests for edge cases:

&  key-word: xyz
   nokey - x: yz

   ;; Some keywords may contain operators as a subpart. If your regexp
   ;; uses \b to single out operators like each, is or in, you may
   ;; fail to highlight these properly:
   beaches           ;; Do not highlight each inside the word beaches
   each-thing        ;; Do not highlight each
   sleep-in          ;; Do not highlight in
   before-each: xyz  ;; Highlight before-each as a keyword
   is-great: xyz     ;; Highlight is-great as a keyword


== Highlighting wishlist

I never implemented these, but I wish someone would:

&  ;; highlight a word followed by indent
   key       ;; <- highlight this; my highlighter doesn't
      x
      nokey
      x



== Existing code

For this website, I highlight EG using the
highlight.js @@ https://highlightjs.org/
library. The code for the syntax mode is
here @@ https://github.com/breuleux/eg-doc/blob/master/hl.eg

It is fairly basic. It doesn't do string interpolation, nor does it
have fancy features like highlighting function arguments. But I only
have so much time!

Feel free to do better :\)


= Editor support

Please follow [the guidelines above]@@[#syntaxhighlighting] for syntax
highlighting.

You can use [the REPL]@@{siteroot}repl/ as a baseline of what I
believe minimum editor support should be like.

* My convention for indent is 3 spaces. It is an uncommon convention,
  but I think it looks best for EG (but feel free to disregard my
  advice).

* The editor should start a new indented block if the previous line
  ends with an operator (chiefly `[:], `[=], `[->], `each, `where,
  etc.), or an opening bracket.

  You may want to amend this rule for suffix `[++] or `[--]~; a more
  general way is to check whether the trailing operator is preceded by
  whitespace. In other words, `[a ++] would indent the next line,
  but `[a++] would not.

Some features not found in the REPL (I'm lazy) but recommended:

* Remember that a leading backslash indicates that the current line
  continuates the previous. Format accordingly.

* The auto-indent functionality for a selected block of text should
  indent the first line of the block but _preserve the relative layout
  of all the other lines, so e.g. if the second line is indented 5
  more than the first, this remains true.



meta ::
   title = Earl Grey documentation
   author = Olivier Breuleux
   summary =
      Install and use
   template = twocol

[\label _@@ \url] => __[{label} @@ {url}]


div#toc %
  js :: //document.getElementById("use").className = "navlink curnav dropdown"
  toc::below
div#main % [

= Install

First you will need to install:

* iojs_@@{iojs}, which is a fork of node.js with support for ES6.
  .note %
    If you have `node installed, you can use the `earl5 command instead
* npm_@@{npm}, the package manager for node/iojs

iojs => https://iojs.org/en/index.html
npm => https://www.npmjs.com/

Once `iojs and `npm are installed, run:

bash &    npm install -g earlgrey

This will install the `earl command. Run `earl (or `earl5 if you don't
have `iojs installed) with no arguments to start an interactive
interpreter, or run an EG program as:

bash &    earl run file.eg


= Runtime

Earl Grey scripts depend on the `earlgrey-runtime package. You don't
need to install it if you run a script with `[earl run], but for all
the other methods you will need to do execute this in the root
directory of your project:

bash &    npm install earlgrey-runtime --save


= Workflow

At the moment you can use EG standalone, compile it, use it with
gulp_@@{gulp}, and/or run it in the browser with
browserify_@@{browserify}.

gulp => https://github.com/gulpjs/gulp/blob/master/docs/getting-started.md
browserify => http://browserify.org

=== Standalone

Run a script like this:

bash &    earl run script.eg

`earl will cache the result of compilation in `egcache/script.js (and
does so with all dependencies). This means that the second time you
run your script, it should start running nearly instantaneously, and
if you change one file, only that file will be recompiled.

If you run into issues, you may force recompilation of your script and
of _all of its dependencies with the `[-r] flag:

bash &    earl run -r script.eg

If you only want to trigger recompilation of a single file, use the
`touch utility to change its last change date. That will do the trick :\)


=== Compile

Compile a script or all the scripts within a directory with:

bash &
    earl compile file.eg
    earl compile -o dest.js file.eg
    earl compile -o dest/ src/

The `[-s] flag writes source maps, I recommend using it. By default
`earl generates EcmaScript 6 code. You can generate ES5 code instead
with the `5 flag.

For instance, the command that follows verbosely compiles `src/**/*.eg
into ES5-compatible `dest/**/*.js (using babel):

bash &    earl compile -5vso dest/ src/

As with `[earl run], `[earl compile] avoids needless recompiling. Use
the `[-r] flag to force recompilation.

You will not be able to run the compiled scripts without first
installing the runtime@@[#runtime].


=== With gulp

The [gulp-earl]_@@{gulpe} package defines a source transformer for use with
`gulp. It supports source maps via the [gulp-sourcemaps]@@{gulpsm}
package.

gulpe => https://github.com/breuleux/gulp-earl
gulpsm => https://github.com/floridoo/gulp-sourcemaps

Here's a sample task for your `gulpfile.js

javascript &
    var earl = require('gulp-earl');

    gulp.task('earl', function() {
      gulp.src('./src/**/*.eg')
        .pipe(earl({}))
        .pipe(gulp.dest('./build/'))
    });

.tip %
  You can also write gulpfiles in Earl Grey. The [earl-gulp]_@@{egulp}
  package defines a neat `task macro for the purpose. Do note that
  this is the `earl-gulp package and not the `gulp-earl package. They
  are different (sorry for the confusion!)

egulp => https://github.com/breuleux/earl-gulp

Don't forget to also install the runtime@@[#runtime].


=== In the browser

In order to use EG scripts in the browser, it is necessary to bundle
them using browserify_@@{browserify}.
br %
The earlify_@@{earlify} package defines a source transformer for use with
`browserify. Install it:
bash &    npm install earlify --save
Then run it like this:
bash &    browserify -t earlify script.eg > bundle.js
Don't forget to also install the runtime@@[#runtime].
.note %
  Global variables like `document or `window are not available by
  default in Earl Grey. You must declare them like this:
  &   globals:
         document, window
  The same goes if you include external scripts on your page and they
  declare global variables that you want to use: declare their
  existence in a `globals block, then use them as you normally would.


= What does it look like?

I am not sure what are the best examples to give here. Let's start
with a straightforward example, counting all unique words in a
paragraph of text:

&   countWords(text) =
       counts = new Map()
       words = text.split(R"\W+")
       words each word ->
          currentCount = counts.get(word) or 0
          counts.set(word, currentCount + 1)
       consume(counts.entries()).sort(compare) where
          compare({w1, c1}, {w2, c2}) = c2 - c1


__Generators: the following defines a generator for the Fibonacci
sequence and then prints all the even Fibonacci numbers less than
100. It shows off a little bit of everything:

&   gen fib() =
       var {a, b} = {0, 1}
       while true:
          yield a
          {a, b} = {b, a + b}

    fib() each
       > 100 ->
          break
       n when n mod 2 == 0 ->
          print n

The `each operator accepts multiple clauses, which makes it
especially easy to work on heterogenous arrays.

__Asynchronous: EG has async and await keywords to facilitate
asynchronous programming, all based on Promises. Existing
callback-based functionality can be converted to Promises using
`promisify:

&   require: request
    g = promisify(request.get)
    async getXKCD(n = 0) =
       response = await g('http://xkcd.com/info.{n}.json')
       JSON.parse(response.body)
    async:
       print (await getXKCD()).alt


Also: __classes:

&   class Person:

       ;; Instance @fields can be set directly in argument lists
       constructor(@name, @age, @job = "unemployed") =
          pass

       ;; Default arguments
       marchTowardsDeath(years = 1) =
          @age += years

       ;; Individual arguments can be matched on
       sayHello(match) =
          ;; This matches a Person instance and extracts its name field
          ;; or else it matches a String directly
          Person? {=> name} or String? name ->
             print 'Hello {name}, I am {@name}!'
          ElderGod? ->
             print "AAAAAAAHHHHHHHHHHHHHHHH!"
          else ->
             print "I don't know what to say."

    ;; .xyz is the same thing as "xyz", just a bit shorter to type
    p1 = new Person(.Sylvie, 37, .accountant)
    ;; You don't have to use "new"
    p2 = Person(.Michel, 43, .farmer)
    p1.sayHello(p2)


__Pattern matching is very useful. It makes it easier to work with
regular expressions, for example:

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

= Tooling support

Click here @@ {siteroot}tooling.html
for details about current support for editors and syntax highlighting.

Read this @@ {siteroot}contrib.html
if you wish to contribute tools for popular editors or libraries.


= Learn more

* Go through the [interactive tutorial _@@ {siteroot}repl]. It
  runs in your browser, no need to install anything!

* See the [documentation _@@ {siteroot}doc.html] for an overview of
  all of EG's features.

]

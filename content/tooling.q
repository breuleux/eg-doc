
template :: default

meta ::
  title = Tooling
  author = Olivier Breuleux
  summary =
    Tooling for Earl Grey

;; resources ::
  toc-scroll.js

store sidebar ::
  toc::

js :: document.querySelector("#nav-main > ul > :nth-child(4)").className = "dropdown curnav"

[\label _@@ \url] => __[{label} @@ {url}]
[\label _@@@ \url] => __[{label} @@@ {url}]
[@@! \project] => {project} _@@ https://github.com/breuleux/{project}

= Editor support

Editor support is a bit scattered at the moment. Please tell me if you
are using these modules and file any issues you encounter.

* __Emacs: @@!earl-grey-mode

* __Atom: {atomearl}

* __CodeMirror: {cmearl}; browserify+earlify it and include the file,
  it should work. Tell me if you try to work with it.

atomearl => [language-earl-grey]_@@https://atom.io/packages/language-earl-grey
cmearl => [earlmode.eg]_@@[https://github.com/breuleux/repple/blob/master/src/earlmode.eg]

If you wish to __contribute editor support for an editor which is not
yet supported, please consult these
[guidelines]_@@@contrib.html#editorsupport.


= Syntax highlighting

Also scattered.

* __highlight.js: [hleg.eg]_@@[https://github.com/breuleux/quaint-highlight/blob/master/src/hleg.eg]

If you wish to __contribute syntax highlighting for a library which is
currently not supported, please consult these
[guidelines]_@@@contrib.html#syntaxhighlighting.


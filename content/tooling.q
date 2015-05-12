
meta ::
   title = Tooling
   author = Olivier Breuleux
   summary =
      Tooling for Earl Grey
   template = twocol

div#toc %
  toc::below
div#main % [

[\label _@@ \url] => __[{label} @@ {url}]
[@@! \project] => {project} _@@ https://github.com/breuleux/{project}
[\maybe\text @@@ \maybe\path] => {text}@@{siteroot}{path}

= Editor support

Editor support is a bit scattered at the moment. Please tell me if you
are using these modules and file any issues you encounter.

* __Emacs: @@!earl-grey-mode

* __CodeMirror: {cmearl}; browserify+earlify it and include the file,
  it should work. Tell me if you try to work with it.

cmearl => [earlmode.eg]@@[https://github.com/breuleux/repple/blob/master/src/earlmode.eg]

If you wish to __contribute editor support for an editor which is not
yet supported, please consult these
[guidelines]_@@{siteroot}contrib.html#editorsupport.


= Syntax highlighting

Also scattered.

* __highlight.js: [hl.eg]@@[https://github.com/breuleux/eg-doc/blob/master/hl.eg]

If you wish to __contribute syntax highlighting for a library which is
currently not supported, please consult these
[guidelines]_@@{siteroot}contrib.html#syntaxhighlighting.




]



meta ::
  title = Try Earl Grey!
  author = Olivier Breuleux
  summary =
    REPL for Earl Grey.
  include =
    https://jspm.io/system@0.16.js
    /lib/eg.js
    /repl/repl.js
    /repl/style/repl.css
    /repl/style/codemirror.css
  template = nav

resources ::
  //jspm.io/system@0.16.js
  eg.js
  repl.js
  repl/repl.css
  repl/codemirror.css

div#repl-container.container %

  div #box %
    div #interactive %
    div #inputline .in .hasinput %
      div .inbanner %
      div #inputbox %
        textarea #code % []

  div #help % []

js ::
  document.getElementById("repl").className = "navlink curnav"
  repl = require("repl").setup();


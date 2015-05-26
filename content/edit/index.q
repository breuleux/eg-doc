
meta ::
   title = Try Earl Grey!
   author = Olivier Breuleux
   summary =
      Editor for Earl Grey.
   include =
      https://jspm.io/system@0.16.js
      /edit/edit.js
      /edit/style/edit.css
      /repl/style/codemirror.css
   template = boilerplate

div #ed-main %
  div #editor %
     textarea #textarea-editor % []
  div #result % []

js ::
  ed = require("edit").setup();

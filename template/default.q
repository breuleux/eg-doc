
meta :: template = boilerplate

logo =>
  img %
    src = {siteroot}assets/earlgrey-text.svg
    height = 70px
    alt = Earl Grey
repo => https://github.com/breuleux/earl-grey

[\maybe\text @@@ \maybe\path] => {text}@@{siteroot}{path}

div#nav %
  * div#logo.navlink % {logo} @@@
  * div.navlink #doc % Doc @@@ doc.html
  * div.navlink #repl % Try it! @@@ repl
  * div.navlink #source % Source @@ {repo}

div#body %
  div#main %
    {body}

div#foot %
  * .footlink % []

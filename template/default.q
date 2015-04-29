
meta :: template = boilerplate

logo =>
  img %
    src = {siteroot}assets/earlgrey-text.svg
    height = 70px
    alt = Earl Grey
repo => https://github.com/breuleux/earl-grey

[\maybe\text @@@ \maybe\path] => {text}@@{siteroot}{path}

div#nav-container.container %
  div#nav %
    div#logo.navlink % {logo} @@@
    div.navlink #doc % doc @@@ doc.html
    div.navlink #repl % try it! @@@ repl
    div.navlink #source % source @@ {repo}

div#main-container.container %
  div#main %
    {body}

div#foot-container.container %
  div#foot %
    .footlink % []

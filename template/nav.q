
template :: boilerplate

logo =>
  img %
    src = {siteroot}assets/earlgrey-text.svg
    height = 60px
    alt = Earl Grey
github =>
  img %
    title = breuleux/earl-grey
    src = {siteroot}assets/github.png
    height = 32px
    alt = breuleux/earl-grey on GitHub
twitter =>
  img %
    title = @earlgreylang
    src = {siteroot}assets/twitter.png
    height = 50px
    alt = @earlgreylang

repo => https://github.com/breuleux/earl-grey

div#sidebar %
  div#sidebar-contents %
    store sidebar :: dump!

div#nav-container.container %
  div#nav %
    div#logo.navlink % {logo} @@@ index.html
    div.navlink.dropdown #use %
      span % learn @@@ use.html
      * Install @@@ use.html
      * Documentation @@@ doc.html
      * Tooling @@@ tooling.html
      * Contribute @@@ contrib.html
    ;; div.navlink.dropdown #posts-nav %
      span % posts @@@ posts/index.html
      * Install @@@ posts/one
    div.navlink #repl % try it! @@@ repl.html
    div #social %
       div.navlink #source % {github} @@ {repo}
       div.navlink #twitter % {twitter} @@ https://twitter.com/earlgreylang

{body}

div#foot-container.container %
  div#foot %
    []

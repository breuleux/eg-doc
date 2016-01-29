template :: @nav
logo =>
  inherit %
    height = 60px
    alt = Earl Grey
    @@@image:assets/earlgrey-text.svg
github =>
  inherit %
    title = breuleux/earl-grey
    height = 32px
    alt = breuleux/earl-grey on GitHub
    @@@image:assets/github.png
twitter =>
  inherit %
    title = @earlgreylang
    height = 50px
    alt = @earlgreylang
    @@@image:assets/twitter.png
repo => https://github.com/breuleux/earl-grey
nav ::
  * [#logo % {logo}] @@@ index.html
nav ::
  li.spacer0 %
nav ::
  * [learn @@@ use.html]
    * Install @@@ use.html
    * Documentation @@@ doc.html
    * Tooling @@@ tooling.html
    * Contribute @@@ contrib.html
  * try it! @@@ repl.html
nav ::
  li.spacer %
nav ::
  * inherit.github-badge % {github} @@ {repo}
  * inherit.twitter-badge % {twitter} @@ https://twitter.com/earlgreylang

{body}

;; div#main-container.container %
  div#main %
    {body}

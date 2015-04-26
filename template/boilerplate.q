
raw % <!DOCTYPE html>

html %

  head %
    meta %
       http-equiv = Content-type
       content = text/html
       charset = UTF-8
    title % meta :: title
    link %
       rel = stylesheet
       type = text/css
       href = /style/style.css
    {
       incl = String{doc.meta.get{.include} or ""}
       incl.split{R" *\n *"} each
          "" -> ""
          R".css$"? lnk ->
             link %
                rel = "stylesheet"
                type = "text/css"
                href = lnk
          R".js$"? script ->
             script %
                src = script
    }

  body %
    {body}


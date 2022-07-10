---
title: Markdown notes
description: Notes on implementation of markdown in mkdocs-material

---

PyMdown Extensions
https://facelessuser.github.io/pymdown-extensions/extensions/arithmatex/

:smile:

Add some recommended extensions:
``` yaml
--8<-- "mkdocs.yml"
```
Add some triggerscript:
``` bash
--8<-- "docs/triggerscript.sh"
```

List of markdown options
https://squidfunk.github.io/mkdocs-material/reference/

List of markdown extensions (NB not all supported by Material for MkDocs)
https://squidfunk.github.io/mkdocs-material/setup/extensions/python-markdown-extensions/

To highlight codeblocks, enclose them in triple backwards quotes and also use https://pygments.org/docs/lexers/ to give the language at the start and add `linenums="1"` if you want to add line numbers:
```` markdown
``` bash linenums="1"
cd newdir
```
````

First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell

This page was last updated: *{{ git_revision_date_localized }}*
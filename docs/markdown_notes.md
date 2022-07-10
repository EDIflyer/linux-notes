---
title: Markdown notes
description: Notes on implementation of markdown in mkdocs-material

---

PyMdown Extensions
https://facelessuser.github.io/pymdown-extensions/extensions/arithmatex/

Add some recommended extensions:
``` yaml linenums="1" hl_lines="3-6 8"
site_name: Tech & Programming Notes

theme:
  name: material
  palette:
    # Palette toggle for light mode
    - scheme: default
      primary: deep orange
      toggle:
        icon: material/brightness-7 
        name: Switch to dark mode

    # Palette toggle for dark mode
    - scheme: slate
      primary: deep orange
      toggle:
        icon: material/brightness-4
        name: Switch to light mode

plugins:
  - search
  - git-revision-date-localized

markdown_extensions:
  # Python Markdown
  - abbr
  - admonition
  - attr_list
  - def_list
  - footnotes
  - meta
  - md_in_html
  - toc:
      permalink: true

  # Python Markdown Extensions
  - pymdownx.arithmatex:
      generic: true
  - pymdownx.betterem:
      smart_enable: all
  - pymdownx.caret
  - pymdownx.details
  - pymdownx.emoji:
      emoji_index: !!python/name:materialx.emoji.twemoji
      emoji_generator: !!python/name:materialx.emoji.to_svg
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.inlinehilite
  - pymdownx.keys
  - pymdownx.mark
  - pymdownx.smartsymbols
  - pymdownx.snippets
  - pymdownx.superfences
  - pymdownx.tabbed:
      alternate_style: true
  - pymdownx.tasklist:
      custom_checkbox: true
  - pymdownx.tilde
```

List of markdown options
https://squidfunk.github.io/mkdocs-material/reference/

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
---
description: Notes on implementation of markdown in mkdocs-material
---
## General introduction
The documentation is built using markdown files - basically plaintext with some simple additions for emphasis and to draw attention to elements.  It uses [Material for MkDocs](https://github.com/squidfunk/mkdocs-material) as a quick and easy way to make nice-looking documentation. 

!!! danger "Warning re `mkdocs.yml`"
    Please do not edit the `mkdocs.yml` file in the root of the `docs` directory unless you are sure of what you are doing as it risks breaking the site and stopping it from building!

[Microsoft Visual Studio Code](https://code.visualstudio.com/) is the recommended editor as it is lightweight, handles markdown files well as well and has good Github integration.  It also has a markdown preview function that, although it doesn't cover all the features of Material for MkDocs does cover the basics...
![](images/vscodepreview.png)

![](images/edit.png){ align=right }
After a push to Github the documentation site will be rebuilt (usually takes ~5s).  The navigation and search indices are automatically generated based on contents (including heading levels used in the markdown files). 

If just making a quick edit then this can be done directly on Github by just clicking the 'edit' button at the top of the page:  

## Navigation
These will all default to alphabetical order but thanks to the [MkDocs Awesome Pages plugin](https://github.com/lukasgeiter/mkdocs-awesome-pages-plugin) this can be varied by creating a `.pages` file within the folder and explicitly specifying the order there.  List the files and subdirectories in the order that they should appear in the navigation. Pages or sections that are not mentioned in the list will not appear in the navigation. However, you may include a `...` entry to specify where all remaining items should be inserted.
!!! abstract "example `.pages` file"
    ``` yaml
    --8<-- "docs/.pages"
    ```

Section names are based on the folder names and individual pages on the markdown file names, although this can be overridden by setting a title in the header (see the markdown at the top of this page as an example), but more easily this can be done by specifying it in the `.pages` files.  Items can be grouped into sections too:
!!! abstract "example `.pages` file"
    ``` yaml
        nav:
            - introduction.md
            - Section 1:
                - Page 1 title: page1.md
                - Page 2 title: page2.md
            - Section 2:
                - ...
    ```

!!! danger "Warning when making changes"
    An invalid `.pages` file will stop the site from building!  If you see the below error then in the first instance I would revert the change just made to the `.pages` file and see if that resolves.  
    ![](images/502.png)

For sections with only one page you can also show only the page without the section by setting `collapse: true` in the `.pages` file for that folder.  If you want to hide a directory from the navigation structure but still have it available to link to then `hide: true`.  There are lots of other potential tweaks outlined in the [Awesome Pages readme](https://github.com/lukasgeiter/mkdocs-awesome-pages-plugin#readme).

## Links
Links in general are made by putting the link text in square brackets and the target URL in round brackets afterways - if this is to other documents within the documentation site just a relative link to the markdown file is required - e.g., `[server notes](../documentation-server-setup/server_setup.md)` creates a link to [server notes](documentation-server-setup/server_setup.md).

For internal links within a page or on another markdown page, just use `#` and the relevant title/sub-title, replacing spaces with hyphens (e.g., [`documentation-server-setup/webhooks_setup/#github-setup`](documentation-server-setup/webhooks_setup/#github-setup))

!!! tip "Quick internal links in VS Code"
    In VS Code if you type the `../` after the round bracket it will bring up a pop-up to make it easier to navigate to file for internal link...  
    ![](images/2022-07-13-01-02-58.png)

If it is to a page elsewhere then provide a full URL, for Github there is a shorthand - to link to an issue or pull request in the current  repository just enter `!<issue/PR number>` and the Github URL elements will be automatically added - e.g., !33 or !624.  If it is in a different repository then you can specify that too as `!<username/repo!number>` - e.g., EDIflyerrepo2/linux-notes!1

## Markdown options
A complete explanation of the different markdown options within MkDocs-Material is [available](https://squidfunk.github.io/mkdocs-material/reference/), although a reasonable number are also used to create the [documentation server setup pages](documentation-server-setup/server_setup.md) within this site so feel free to have a look at the markdown there.

!!! warning "Carriage returns"
    Merely pressing ++enter++ at the end of a line will not create a new one!  
    To create a new line in markdown (equivalent of `<BR>`) just place two spaces at the end of the line.   
    
    For a space as well (equivalent of `<P>`) press ++enter++ twice.

If taking an existing document then a regex search and replace in [Notepad++](https://notepad-plus-plus.org/downloads/) is an easy way to add two spaces to the end of each line (the replace box as two spaces in it):  
![](images/regex-end-of-line.png)  
Or to add a `-` to the start of each line:  
![](images/regex-start-of-line.png)  

Handy markdown cheatsheet: https://yakworks.github.io/docmark/cheat-sheet/  
Markdown tutorial: https://commonmark.org/help/tutorial/

To highlight codeblocks, enclose them in triple backwards quotes and also use the appropriate [lexer *shortname*](https://pygments.org/docs/lexers/) to give the language at the start and add `linenums="1"` if you want to add line numbers and/or `hl_lines` if you want to highlight lines:
=== "Markdown"
    ```` markdown
    ``` bash linenums="1" hl_lines="2 4"
    cd newdir
    nano testfile.sh
    chmod +x testfile.sh
    cd ~
    ```
    ````
=== "Result"
    ``` bash linenums="1" hl_lines="2 4"
    cd newdir
    nano testfile.sh
    chmod +x testfile.sh
    cd ~
    ```

## Admonitions
A [full list](https://squidfunk.github.io/mkdocs-material/reference/admonitions/#supported-types) is available in the MkDocs-Material documentation but please note the following three have been redefined on this site to have slightly different icons/usage:

!!! warning "Custom admonitions used on this documentation site"
    === "Code"
        ``` yaml
        example: fontawesome/solid/file-code
        quote: fontawesome/solid/terminal
        tip: fontawesome/solid/lightbulb
        ```
    === "Result"
        !!! example "Example (used for files containing sample code)"
        !!! quote "Quote (used for terminal commands)"
        !!! tip "Tip (used for useful hints)"

Remember for lists to add a blank line **before and after** starting the list.  An unordered list just needs `- ` and for checked/unchecked boxes it is `- [x]`/`- [ ]`. For numbered lists a period is required after the number (incremental numbers don't need to be used, just use `1.` and it will automatically calculate the sequence).  Also remember if adding an admonition to a list to add a blank line between items and also to indent appropriately to ensure it appears within that list item.

## Paste Image plugin
This plugin is very useful for adding images to documentation.  Install it from the [VS Marketplace](https://marketplace.visualstudio.com/items?itemName=mushan.vscode-paste-image) and set `Paste Image: path` to `images` so they go into a subdirectory:
![](images/2022-07-09-18-34-46.png)

!!! info "Usage of Paste Image"
    Use ++ctrl+alt+v++ to paste. 

## Diagrams
MkDocs Material [includes support](https://squidfunk.github.io/mkdocs-material/reference/diagrams) for [Mermaid.js](https://mermaid-js.github.io/mermaid) diagrams:
=== "Code"
    ```` markdown
    ``` mermaid
    graph LR
    A[Start] --> B{Error?};
    B -->|Yes| C[Hmm...];
    C --> D[Debug];
    D --> B;
    B ---->|No| E[Yay!];
    ```
    ````
=== "Result"
    ``` mermaid
    graph LR
    A[Start] --> B{Error?};
    B -->|Yes| C[Hmm...];
    C --> D[Debug];
    D --> B;
    B ---->|No| E[Yay!];
    ```

## Wakatime
Opensource solution to track coding stats: https://wakatime.com/  
Easiest to sign up via Github account.  
It has plugins for both VS Code and Visual Studio (just install via extensions and enter the API key from the Wakatime website) - remember if doing remote development work on SSH to install on the SSH server too!
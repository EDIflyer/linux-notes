---
title: "VS Code notes"
date: 2022-07-09T18:32:03+01:00
---
## WSL I/O error
If seeing this error then from within the WSL terminal, run
```bash
rm -r ~/.vscode-server 
```
to delete the VS Code WSL server.
Exit the terminal and from your PowerShell/Cmd, run
```msdos
wsl --shutdown
```
Then you can go back to WSL and run `code .` and it should work normally.

## Git hooks
Create a `.githooks` directory in the repo and then instruct git to use it to run the hooks:

``` bash
mkdir -p .githooks
git config core.hooksPath .githooks
```
Ensure any Git hooks that are then created have a `chmod +x` run on them otherwise they will not be marked as executable and will not run on Linux systems (it doesn't seem to be an issue on Windows).

## Paste Image plugin
=== "Install extension"
    ```
    Name: Paste Image
    Id: mushan.vscode-paste-image
    Description: paste image from clipboard directly
    Version: 1.0.4
    Publisher: mushan
    VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=mushan.vscode-paste-image
    ```

???+ tip "Path settings"
    Set `Paste Image: Base Path` to `${currentFileDir}` and `Paste Image: path` to `${projectRoot}/docs/images` so they go into an images subdirectory and are correctly referenced by the markdown files.

## Spellcheck plugin
https://github.com/streetsidesoftware/vscode-spell-checker
Turn on English (GB) by changing "cSpell.language": "en" to "cSpell.language": "en-GB"

## Wakatime
https://wakatime.com/
Tracks coding work
Remember to also install on the remote host if doing SSH remote work

## Test items

EKORA(r) by Clinical IT(c)

???+ note "Open styled details"

    ??? danger "Nested details!"
        And more content again.

:fontawesome-regular-face-laugh-wink:

:octicons-code-16:

:fontawesome-solid-code-fork:

!!! info "Usage"
    Use ++ctrl+alt+v++ to paste. 

- [ ] item 1
- [x] item 2

H~2~O

~~Delete this~~  O^2^

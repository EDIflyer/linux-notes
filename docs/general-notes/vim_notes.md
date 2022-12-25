## Install `neovim`
``` bash
wget --quiet https://github.com/neovim/neovim/releases/latest/download/nvim.appimage --output-document nvim
chmod +x nvim
sudo chown root:root nvim
sudo mv nvim /usr/bin
cd ~
mkdir -p .config/nvim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

``` bash
nvim
pip3 install --user neovim
```

!!! example `~/.config/nvim/init.vim`
    ``` bash
    call plug#begin()
    Plug 'ncm2/ncm2'
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
    Plug 'ThePrimeagen/vim-be-good'
    call plug#end()
    ```

``` vim
nvim
:PlugInstall
:UpdateRemotePlugins
:q!
:q!
```

After new plugin added to nvim init file then rerun `PlugInstall`

Once installed then to run [ThePrimeagen game tutorial](https://github.com/ThePrimeagen/vim-be-good) - `:VimBeGood`
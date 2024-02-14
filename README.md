<h1><p align=center>Training.nvim</p></h1>
<h3><p align=center><sup>VIM motions training / games</sup></p></h3>
<br \><br \>

![Screenshot 1](https://raw.githubusercontent.com/Ernest1338/meta/main/training.nvim/Screenshot_20240215_000333.png)

## ⚙️ Features
- Multiple training games:
- - hjkl
- - relative
- - whack a mole
- - change text
- - random

## 📦 Installation
- With [folke/lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{ "Ernest1338/training.nvim" }
```

- With [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use "Ernest1338/training.nvim"
```

- With [echasnovski/mini.deps](https://github.com/echasnovski/mini.deps)
```lua
add("Ernest1338/training.nvim")
```

## 🚀 Usage
Firstly, call the `setup` function (for the `Training` command)
```lua
require("training").setup()
```

Then use the `Training` command to show the game window

Use the `VD` motion to select a option

## ⚡ Requirements
- Neovim >= **v0.7.0**

## License

MIT


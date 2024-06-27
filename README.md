# scratchpad.nvim

Have a handy scratchpad contained within a floating window and saved at `.scratchpad.md` on the root of your directory. Use it for taking notes or a todo.

## Installation

Packer
```
use 'mzguntalan/scratchpad.nvim'
```

## Usage
### Basic Usage
```lua
require('scratchpad').setup({})
```

### All Configurable Parameters
Here are the defaults
```lua
opts = {
    keymap = {
        toggle = '<C-S-p>',
        done_undone = '<C-S-o>',
    },
    width = 0.5,  -- 50% of screen width
    height = 0.7, -- 70% of screen height
    file_path = '.scratchpad.md'
}

require('scratchpad').setup()
```

# vim-shell

My failed attempt at a shell emulator for Vim. Turns out it is impossible. Mostly because of how Vim does not support async code. Just use NeoVim, it comes with a terminal, or use a real one. I only keep this repo around as example code for useful vimscript.

Run `:Vimshell` to open a new shell. Press enter to run the command line under the cursor. Use up and down to cycle through command history.

`:Vimshell` can also take a single directory as argument. Example:

```shell
:Vimshell %:h
```
Open a new shell in the directory of the current file.

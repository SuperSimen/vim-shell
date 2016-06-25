# vim-shell

Shell emulator for Vim. Apparently a terminal for Vim was not a good idea. Just use a real shell, or switch to emacs maybe.

Run `:Vimshell` to open a new shell. Press enter to run the command line under the cursor. Use up and down to cycle through command history.

`:Vimshell` can also take a single directory as argument. Example:

```shell
:Vimshell %:h
```
Open a new shell in the directory of the current file.

# vim-shell

Terminal emulator for Vim. Run `:Vimshell` to open a new shell. Press enter to run the command line under the cursor. Use up and down to cycle through command history.

`:Vimshell` also takes arguments. If run with arguments it will not start a separate shell but print the result into the current buffer.

```shell
:Vimshell ls -F | grep /
```
The preceding line will paste a list of folders into current buffer.

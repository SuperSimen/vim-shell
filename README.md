# vim-terminal

Terminal emulator for Vim. Run `:Terminal` to open a new terminal. Press enter to run the command line under the cursor. Use up and down to cycle through command history.

`:Terminal` also takes arguments. If run with arguments it will not start a separate terminal but print the result into the current buffer.

```shell
:Terminal ls -F | grep /
```
The preceding line will paste a list of folders into current buffer.

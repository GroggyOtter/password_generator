# A password_generator class for AHKv2

### A GUI-based AHK script that generates passwords based on the options you give it.

To use it, copy and paste the code into your script.  
Everything is a self-contained class and should not interfer with anything in your script.

There are 2 properties that can be adjusted: `hotkey` and `hotstring`
You can add any amount of hotstrings to the `hotstring` array and any hotkeys to the `hotkey` array.  
Each [`Hotstring`](https://www.autohotkey.com/docs/v2/lib/Hotstring.htm) and [`Hotkey`](https://www.autohotkey.com/docs/v2/Hotkey.htm) added to the arrays must be a string and must be in the right format: `:OPTIONS:hotkey` or `:OPTIONS:hotstring`  
Example of adding `F1` and `Control+Numlock` hotkeys: `hotkey := ['F1', '^NumLock']`

If you do not want to use a hotstring or a hotkey, the array should be empty.  
Example for no hotstrings: `hotstring := []`

Pressing `Escape` will destroy the GUI if it exists.

**GUI preview and info:**  
![](https://i.imgur.com/GStsICk.png)

# A password_generator class for AHKv2

A GUI-based AHK script that generates passwords based on the options you give it.

To use it, copy and paste the code into your script.  
The class is self-contained and should not interfere with anything in your script.

There are 2 properties that can be adjusted: `hotkey` and `hotstring`  
You can add any amount of hotstrings or hotkeys to the `hotstring` array or `hotkey` array, respectively.  
Each [`Hotstring`](https://www.autohotkey.com/docs/v2/lib/Hotstring.htm) and [`Hotkey`](https://www.autohotkey.com/docs/v2/Hotkey.htm) array element must be a [`String`](https://www.autohotkey.com/docs/v2/Concepts.htm#strings) and must be in the right format: 

    :Options:HotstringFormat
    OptionsModifiersHotkey

Example of adding an `F1` and a `Control+Numlock` hotkey:

    hotkey := ['*F1', '*^NumLock']

If you do not want to use a hotstring or a hotkey, that array should be empty.  
Example for no hotstrings:

    hotstring := []

Pressing `Escape` destroy the GUI if it exists.

**GUI preview and info:**  
![](https://i.imgur.com/GStsICk.png)


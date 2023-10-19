/**
* @author GroggyOtter <groggyotter@gmail.com>
* @version 1.0
* @see https://github.com/GroggyOtter/password_generator
* @license GNU
* @classdesc GUI-based password generator with multiple options.
* @property {Array} hotstring - Array of strings in hotstring format that will launch the GUI
* @property {Array} hotkey - Array of strings in hotkey format that will launch the GUI
*/
class password {
    #Requires AutoHotkey 2.0.10+
    
    /**
    * Assign any number of hotstrings
    * @property {Array} hotstring - An array of strings in hotstring format  
    * The X option is automatically included.
    * @example hotstring := [':?*:/pass.generate'] ; Typing /pass.generate launches GUI
    */
    static hotstring := [':?*:/password']
    
    /**
    * Assign any number of hotkeys
    * @property {Array} hotkey - An array of strings in hotkey format
    * @example hotkey := ['*F1', '*+F2'] ; F1 and Shift+F2 launch GUI
    */
    static hotkey := []
    
    ; Base character sets
    static char_set :=
        Map('1. Lower'   ,'abcdefghijklmnopqrstuvwxyz'
            ,'2. Upper'  ,'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            ,'3. Number' ,'0123456789'
            ,'4. Symbol' ,'`~!@#$%^&*()-=_+[]\{}|;`':`",./<>?')
    
    ; Settings stuff
    static settings_path := A_AppData '\AHK_Pass'
        , settings_file := 'settings.ini'
        , settings_full := this.settings_path '\' this.settings_file
    
    ; Auto-execute
    static __New() {
        this.settings_check()
        ,this.make_hotkeys()
    }
    
    ; Generates hotkeys and hotstrings
    static make_hotkeys() {
        if this.hotstring.Length
            for _, hs in this.hotstring
                Hotstring(hs, (*) => this.make_gui())
        if this.hotkey.Length
            for _, hk in this.hotkey
                Hotkey(hk, (*) => this.make_gui())
        HotIf((*) => this.gui)
        ,Hotkey('*~Escape', (*) => this.destroy_gui())
        ,HotIf()
    }
    
    ; Generates a random password based on the character bank
    static generate() {
        pass := []
        ,inc := this.string_to_map(this.gui.include.Value)
        ; Ensure password contains the include characters
        for char, _ in inc
            pass.Push(char)
        omit := this.string_to_map(this.gui.omit.Value)
        ,bank := this.build_char_bank(omit, inc)
        ,size := this.gui.length.Value
        ,str := ''
        ; If a bank was successfully generated
        if (bank.length > 1)
            ; Pick random characters until pass size is right
            while (pass.Length < size)
                pass.InsertAt(Random(1, pass.Length), bank[Random(1, bank.Length)])
        
        ; If no password was generated, set string to error message
        if !pass.Length
            str := 'No characters to choose from.'
        ; Else randomly remove characters to create password string
        Else while pass.Length
            str .= pass.RemoveAt(Random(1, pass.Length))
        
        ; Assign text to password box and focus it
        this.gui.edit_pass.Value := str
        ,this.gui.edit_pass.Focus()
    }
    
    ; Builds a bank of characters to use
    ; Exclude chracters are removed and include characters
    static build_char_bank(forbid, include){
        bank := []
        ; Loop through all char sets
        for name, char_str in this.char_set {
            ; Skip if charset isn't checked
            if !this.gui.cb_charset_%name%.Value
                continue
            ; Loop through chars and adjust for forbidden/include
            loop parse char_str {
                if !forbid.Has(A_LoopField)
                    bank.Push(A_LoopField)
                if include.Has(A_LoopField)
                    include[A_LoopField] := 0
            }
        }
        ; Ensure 
        for char, not_used in include
            if not_used
                bank.Push(char)
        return bank
    }
    
    ; Pick a random char from a string
    static rand_char(chars) => SubStr(chars, Random(1, StrLen(chars)), 1)
    
    ; Turns a string of text into a map of letters
    static string_to_map(text) {
        chars := Map()
        loop parse text
            chars.Has(A_LoopField) ? 1 : chars[A_LoopField] := 1
        return chars
    }
    
    ; Generates the GUI and loads saved settings
    static make_gui() {
        margin          := 10
        ,gb_os_x        := 10
        ,gb_os_y        := 16
        ,gb_os_bottom   := 25
        ,cb_pad         := 4
        ,gb_charset_w   := 450
        ,cb_charset_w   := (gb_charset_w - gb_os_x - margin * this.char_set.Count) / this.char_set.Count
        ,gb_length_w    := gb_charset_w * 0.20 - margin
        ,gb_omit_w      := gb_charset_w * 0.40 - margin
        ,gb_inc_w       := gb_charset_w * 0.40
        ,edit_length_w  := gb_length_w - margin - gb_os_x
        ,edit_omit_w    := gb_omit_w - margin - gb_os_x
        ,edit_inc_w     := gb_inc_w - margin - gb_os_x
        ,gb_pass_w      := gb_charset_w * 0.7 - margin
        ,edit_pass_w    := gb_pass_w - margin - gb_os_x
        ,btn_copy_w     := gb_charset_w * 0.15 - margin/2
        ,btn_gen_w      := gb_charset_w * 0.15 - margin/2
        ,default_length := 16
        ,WM_MOUSEMOVE   := 0x0200
        ,update_setting := ObjBindMethod(this, 'update_setting')
        
        goo := Gui('-Caption +AlwaysOnTop -DPIScale +Border -ToolWindow')
        ,goo.MarginX := goo.MarginY := margin
        ,goo.BackColor := 0x0
        ,goo.SetFont('cWhite')
        
        ; Top edit area - Length, Exclude, Include
        loop parse 'length,omit,include', ',' {
            switch A_LoopField {
                ; Pass length edit
                case 'length':
                    goo.AddGroupBox('xm ym w' gb_length_w ' r1 Section', 'Pass Length:')
                    ,con := goo.AddEdit('xs+' gb_os_x ' ys+' gb_os_y ' w' edit_length_w ' r1 +Number')
                    ,default := default_length
                ; Omit specific characters edit
                case 'omit':
                    x := margin + gb_length_w
                    ,goo.AddGroupBox('xs+' x ' ym w' gb_omit_w ' r1 Section', 'Exclude Characters:')
                    ,con := goo.AddEdit('xs+' gb_os_x ' ys+' gb_os_y ' r1 w' edit_omit_w)
                    ,default := ''
                ; Include specific characters edit
                case 'include':
                    x := margin + gb_omit_w
                    ,goo.AddGroupBox('xs+' x ' ym w' gb_inc_w ' r1 Section', 'Must Include Characters:')
                    ,con := goo.AddEdit('xs+' gb_os_x ' ys+' gb_os_y ' r1 w' edit_inc_w)
                    ,default := ''
            }
            con.name := A_LoopField
            ,con.SetFont('cBlack')
            ,con.OnEvent('Change', update_setting)
            ,con.Value := this.load_setting(con.type, con.name, default)
            ,goo.%A_LoopField% := con
        }
        
        ; Character Sets Checkboxes
        opt := 'xm yp+' (margin + gb_os_bottom) ' w' gb_charset_w ' r1 Section'
        goo.AddGroupBox(opt, 'Character Sets:')
        for name, _ in this.char_set
            opt := (A_Index = 1 ? 'xs+' gb_os_x : 'x+' margin) ' ys+' (gb_os_y + cb_pad)
                . ' Checked w' cb_charset_w ' r1'
            ,con := goo.AddCheckbox(opt , name)
            ,con.name := name
            ,con.SetFont('s10 Bold')
            ,con.OnEvent('Click', update_setting)
            ,con.Value := this.load_setting(con.type, con.name, 1)
            ,goo.cb_charset_%name% := con
        
        ; Show password edit
        goo.AddGroupBox('xm yp+' (margin + gb_os_bottom) ' w' gb_pass_w ' r1 Section', 'Password:')
        ,con := goo.AddEdit('xs+' gb_os_x ' ys+' gb_os_y ' w' edit_pass_w ' r1')
        ,con.SetFont('s10 cBlack Bold', 'Courier New')
        ,goo.edit_pass := con
        
        ; Generate button
        con := goo.AddButton('xs+' (gb_pass_w + margin) ' yp w' btn_copy_w, 'Generate')
        ,con.SetFont('Bold')
        ,con.OnEvent('Click', (*) => this.generate())
        ,goo.btn_generate := con
        
        ; Add to clipboard button
        con := goo.AddButton('x+' margin ' yp w' btn_gen_w, 'Clipboard')
        ,con.SetFont('Bold')
        ,con.OnEvent('Click', (*) => this.clipboard())
        ,goo.btn_copy := con
        
        ; Click+Drag to move GUI
        ,callback := ObjBindMethod(this, 'WM_MOUSEMOVE')
        ,OnMessage(WM_MOUSEMOVE, callback)
        
        ; Save, load, and show
        ,this.gui := goo
        ,this.load_gui_pos(&x, &y)
        ,this.gui.Show('x' x ' y' y)
    }
    
    ; Saves last pos and then destroys GUI
    static destroy_gui() {
        if WinExist('ahk_id ' this.gui.Hwnd)
            dhw := DetectHiddenWindows(0)
            ,this.save_gui_pos()
            ,this.gui.Destroy()
            ,this.gui := ''
            ,DetectHiddenWindows(dhw)
    }
    
    ; Fires when mouse movement is detected on GUI
    static WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
        static moving := 0
        WM_NCLBUTTONDOWN := 0x00A1
        ; If lbutton is being held down
        if (wParam = 1)
            ; Tell windows the user is holding left mouse on the title bar
            SendMessage(WM_NCLBUTTONDOWN, 2, , , 'A')
            ; Moving flag is used to save coords on mouse release
            ,moving := 1
        ; If lbutton was released and moving was set to true, save pos and reset moving
        else if moving
            this.save_gui_pos()
            ,moving := 0
    }
    
    ; Puts password onto clipboard and temporarily changes button text to copied
    static clipboard(*) {
        A_Clipboard := this.gui.edit_pass.Value
        ,this.gui.btn_copy.Text := 'Copied!'
        ,this.copy_text_time := A_TickCount
        ,callback := ObjBindMethod(this, 'reset_clipboard_text')
        ,SetTimer(callback, -100)
        ,this.gui.edit_pass.Focus()
    }
    
    ; Reset the "Copied" message to "Clipboard"
    static reset_clipboard_text(*) {
        if (A_TickCount - this.copy_text_time > 1400)
            this.gui.btn_copy.Text := 'Clipboard'
        else SetTimer((*) => this.reset_clipboard_text(), -100)
    }
    
    ; Creates settings directory and file if they don't exist
    static settings_check() {
        template := '; AHK Password Settings `;'
                . '`n`n[GUI]'
                . '`nx=0'
                . '`ny=0'
        FileExist(this.settings_path) ? 1 : DirCreate(this.settings_path)
        FileExist(this.settings_full) ? 1 : FileAppend(template, this.settings_full)
    }
    
    static save_gui_pos() {
        this.gui.GetPos(&x, &y)
        loop parse 'xy'
            this.save_setting('GUI', A_LoopField, %A_LoopField%)
    }
    
    static load_gui_pos(&x, &y) {
        x := this.load_setting('GUI', 'x', 0)
        ,y := this.load_setting('GUI', 'y', 0)
    }
    
    static load_setting(sec, key, default:=unset) =>
        IsSet(default) ? IniRead(this.settings_full, sec, key, default)
                        : IniRead(this.settings_full, sec, key)
    
    static save_setting(sec, key, value) => IniWrite(value, this.settings_full, sec, key)
    
    ; Updates save setting with newly entered values
    ; Also de-duplicates omit and include strings
    static update_setting(obj, info) {
        if (obj.name ~= '(omit|include)')
            this.de_dupe(obj)
        this.save_setting(obj.type, obj.name, obj.value)
    }
    
    ; Removes duplicate chars from a string
    static de_dupe(con) {
        str := ''
        loop parse con.Value
            InStr(str, A_LoopField, 1) ? 1 : str .= A_LoopField
        con.Value := str
        ,ControlSend('{End}', con.Hwnd)
    }
}

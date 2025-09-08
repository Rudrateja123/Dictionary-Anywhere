; ===================================================================
; Dictionary Anywhere (AutoHotkey v1.1)
; Author: Rudra Teja Baswa
; Version: 1.0
; License: MIT
; ===================================================================
; Description:
;   Highlight any word in any app (browser, PDF, Word, etc.)
;   Press Ctrl+Shift+D → A small popup appears above the text
;   showing the first dictionary meaning (fetched online).
;   The popup stays until you move the mouse or click.
;
; Requirements:
;   - AutoHotkey v1.1 (tested on 1.1.37.02)
;   - Internet connection
;
; API Used:
;   Free Dictionary API (https://dictionaryapi.dev/)
; ===================================================================

!d::   ; Hotkey = Alt+D
    ; Save old clipboard contents
    ClipSaved := ClipboardAll
    Clipboard := ""
    Send, ^c
    ClipWait, 1
    if (ErrorLevel) {
        MsgBox, Failed to copy text
        Clipboard := ClipSaved
        return
    }

    word := Trim(Clipboard)
    if (word = "") {
        MsgBox, No word selected
        Clipboard := ClipSaved
        return
    }

    ; Query dictionary API
    url := "https://api.dictionaryapi.dev/api/v2/entries/en/" . word
    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    http.Open("GET", url, false)
    http.Send()
    response := http.ResponseText

    ; Extract first definition (basic JSON parsing)
    pos := InStr(response, """definition"":")
    if (!pos) {
        MsgBox, No definition found for "%word%"
        Clipboard := ClipSaved
        return
    }

    def := SubStr(response, pos+14)
    def := SubStr(def, 1, InStr(def, """")-1)

    ; Get mouse position for popup placement
    MouseGetPos, xpos, ypos
    ypos -= 50  ; show slightly above cursor

    ; Create GUI popup
    Gui, Destroy
    Gui, +AlwaysOnTop -Caption +ToolWindow
    Gui, Margin, 10, 10
    Gui, Add, Text, w400 wrap, % word ": " def
    Gui, Show, x%xpos% y%ypos% NoActivate, DictionaryPopup

    ; Remember initial mouse position
    MouseGetPos, startX, startY
    SetTimer, CheckMouse, 100
return

CheckMouse:
    MouseGetPos, curX, curY
    if (curX != startX or curY != startY or GetKeyState("LButton","P") or GetKeyState("RButton","P") or GetKeyState("Escape","P")) {
        Gui, Destroy
        SetTimer, CheckMouse, Off
        Clipboard := ClipSaved
    }
return

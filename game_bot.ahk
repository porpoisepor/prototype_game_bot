#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;! ALT
;+ SHIFT
;^ CONTROL

#Include globals.ahk
#Include gui_labels.ahk
#Include init.ahk
#Include spell_class.ahk
#Include character_class.ahk
#Include config_class.ahk
#Include gui_callbacks.ahk
#Include helpers.ahk
#Include init.ahk
#Include unit_tests.ahk

loadConfig()
initGUI()

;must be last or else it would close the auto-execute section(?confirm?)
#Include hotkeys.ahk

;MAIN =================================================================================

    qFunc(){
        ;initGUI()
    }

;======================================================================================


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;! ALT
;+ SHIFT
;^ CONTROL

#Include globals.ahk
#Include gui_labels.ahk
#Include config.ahk
#Include init.ahk
#Include spell_class.ahk
#Include character_class.ahk
#Include config_class.ahk
#Include gui_callbacks.ahk
#Include helpers.ahk
#Include init.ahk
#Include unit_tests.ahk


;must be last or else it would close the auto-execute section(?confirm?)
#Include hotkeys.ahk

;MAIN =================================================================================

    qFunc(){
        Gui, font, s8, Consolas
        Gui, Add, Button, +section +w200 +r10, OK
        Gui, Add, Edit, ReadOnly vDisplayText1 +r10 +w590 +wrap +vScroll +ys, aaa
        GuiControl, Text, DisplayText1, % mainChar.toString()
        Gui, Add, Edit, ReadOnly vDebugWindow +r10 +w800 +wrap +section +xs
        Gui, Add, Text, +r1 +wrap +section, Vocation
        Gui, Add, Radio, vVocationRadioGroup +Checked gVocationRadioGroupCallback, Sorcerer
        Gui, Add, Radio, gVocationRadioGroupCallback, Knight
        Gui, Add, Radio, gVocationRadioGroupCallback, Paladin
        Gui, Add, Text, +r1 +wrap +ys, Level
        Gui, Add, Edit, vLevelEdit gLevelEditCallback, 100
        ;Gui, Add, Button, vRefreshDataButton +wrap , Refresh
        Gui, Add, Text, +r1 +wrap +ys, Latency(ms)
        Gui, Add, Edit, vLatencyEdit gLatencyEditCallback, 300
        ;stats
        Gui, Add, Text, +r1 +wrap +ys, maxMana
        Gui, Add, Text, +r1 +wrap , manaRegen
        Gui, Add, Text, +r1 +wrap , autoattackManaPerSec
        Gui, Add, Text, +r1 +wrap , rotationConsumptionPerSec
        Gui, Add, Text, +r1 +wrap , rotationConsumptionPerSecWithLatency
        Gui, Add, Text, +r1 +wrap , spentMana
        Gui, Add, Text, +r1 +wrap , timeForFullMana
        Gui, Add, Text, +r1 +wrap , timeForFullManaConsumption
        Gui, Add, Text, +r1 +wrap , waitTimeBeforeStartingRotation
        Gui, Add, Text, +r1 +wrap , waitTimeBeforeStartingRotationWithLatency
        ;stats
        Gui, Add, Text, +r1 +wrap +w60 +ys vMaxMana, % mainChar.data.maxMana
        Gui, Add, Text, +r1 +wrap +w60 vManaRegen, % mainChar.data.manaRegen
        Gui, Add, Text, +r1 +wrap +w60 vAutoattackManaPerSec, % mainChar.data.autoattackManaPerSec
        Gui, Add, Text, +r1 +wrap +w60 vRotationConsumptionPerSec, % mainChar.data.rotationConsumptionPerSec
        Gui, Add, Text, +r1 +wrap +w60 vRotationConsumptionPerSecWithLatency, % mainChar.data.rotationConsumptionPerSecWithLatency
        Gui, Add, Text, +r1 +wrap +w60 vSpentMana, % mainChar.data.spentMana
        Gui, Add, Text, +r1 +wrap +w60 vTimeForFullMana, % mainChar.data.timeForFullMana
        Gui, Add, Text, +r1 +wrap +w60 vTimeForFullManaConsumption, % mainChar.data.timeForFullManaConsumption
        Gui, Add, Text, +r1 +wrap +w60 vWaitTimeBeforeStartingRotation, % mainChar.data.waitTimeBeforeStartingRotation
        Gui, Add, Text, +r1 +wrap +w60 vWaitTimeBeforeStartingRotationWithLatency, % mainChar.data.waitTimeBeforeStartingRotationWithLatency

        ;meta
        Gui, Add, Checkbox, +wrap vPrintInsteadOfPress gPrintInsteadOfPressCallback +ys, Send to debug window EXCLUSIVELY
        Gui, Add, Checkbox, +r1 +wrap vMuteDebugButton gMuteDebugButtonCallback, Mute Debug
        Gui, Add, Checkbox, +r1 +wrap vCopyInputFromGameToScreenCheckbox gCopyInputFromGameToScreenCheckboxCallback, Show game input
        Gui, Add, Button, +r1 +wrap vStartRotation gStartRotationCallback, Start Rotation
        Gui, Add, Checkbox, +r1 +wrap vStopRotation gStopRotationCallback, Stop Rotation

        Gui, Show
        refreshGUI()
        ;maxMana: 420
        ;manaRegen: 16
        ;autoattackManaPerSec: 0
        ;rotationConsumptionPerSec: 290.000000
        ;rotationConsumptionPerSecWithLatency: 231.103679
        ;spentMana: 0
        ;timeForFullMana: 26.250000
        ;timeForFullManaConsumption: 1.448276
        ;timeForFullManaConsumptionWithLatency: 1.817366
        ;waitTimeBeforeStartingRotation: 24.801724
        ;waitTimeBeforeStartingRotationWithLatency: 24.432634
    }

;======================================================================================


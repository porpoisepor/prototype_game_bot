;GUI CALLBACKS =================================================================================

    vocationRadioGroupCallback(){
        Gui, Submit, NoHide
        debugPrint("VocationRadioGroupCallback called, result: " VocationRadioGroup)
        refreshGUI()
    }
    levelEditCallback(){
        Gui, Submit, NoHide
        debugPrint("LevelEditCallback called, result:" LevelEdit)
        refreshGUI()
    }
    LatencyEditCallback(){
        Gui, Submit, NoHide
        debugPrint("LatencyEditCallback called, result: " LatencyEdit)
        refreshGUI()
        recalculateAllSpellLatencies()
        refreshGUI()
    }
    PrintInsteadOfPressCallback(){
        Gui, Submit, NoHide
        printInsteadOfSendHotkey := PrintInsteadOfPress
        debugPrint("PrintInsteadOfPressCallback called, result: " PrintInsteadOfPress)
    }
    StartRotationCallback(){
        Gui, Submit, NoHide
        debugPrint("StartRotationCallback called, starting continuous rotation.")
        doContinuousRotation()
    }
    StopRotationCallback(){
        Gui, Submit, NoHide
        debugPrint("StopRotationCallback called, result: " StopRotation)
        stop := StopRotation
    }
    MuteDebugButtonCallback(){
        Gui, Submit, NoHide
        debugPrint("MuteDebugButtonCallback called, result: " MuteDebugButton)
        muteDebug := MuteDebugButton
    }
    CopyInputFromGameToScreenCheckboxCallback(){
        Gui, Submit, NoHide
        debugPrint("CopyInputFromGameToScreenCheckboxCallback called, result: " CopyInputFromGameToScreenCheckbox)
        copyInputFromGameToScreen := CopyInputFromGameToScreenCheckbox
    }
    refreshGUI(){
        guiData := getGUIData()
        latency := guiData.latency
        mainChar.init(guiData.level, guiData.vocation, 0)
        GuiControl, Text, MaxMana, % mainChar.data.maxMana
        GuiControl, Text, ManaRegen, % mainChar.data.manaRegen
        GuiControl, Text, AutoattackManaPerSec, % mainChar.data.autoattackManaPerSec
        GuiControl, Text, RotationConsumptionPerSec, % mainChar.data.rotationConsumptionPerSec
        GuiControl, Text, RotationConsumptionPerSecWithLatency, % mainChar.data.rotationConsumptionPerSecWithLatency
        GuiControl, Text, SpentMana, % mainChar.data.spentMana
        GuiControl, Text, TimeForFullMana, % mainChar.data.timeForFullMana
        GuiControl, Text, TimeForFullManaConsumption, % mainChar.data.timeForFullManaConsumption
        GuiControl, Text, WaitTimeBeforeStartingRotation, % mainChar.data.waitTimeBeforeStartingRotation
        GuiControl, Text, WaitTimeBeforeStartingRotationWithLatency, % mainChar.data.waitTimeBeforeStartingRotationWithLatency
    }
    getGUIData(){
        Gui, Submit, NoHide
        vocation := vocations[VocationRadioGroup - 1]
        level := LevelEdit
        latency := LatencyEdit
        ;VocationRadioGroup
        ;LevelEdit
        ;LatencyEdit
        debugPrint("vocation, level, latency: " vocation ", " level ", " latency)
        return { "vocation": vocation, "level": level, "latency": latency}
    }

;========================================================================================
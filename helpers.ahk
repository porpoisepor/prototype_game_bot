;HELPERS ==============================================================================

    ; NOT being used yet
    class sorcererProfile{
        static spellPlan := ["invisibility", "hells core", "rage of the skies"]
    }
    changeLevel(){
        mainChar.changeLevel(mainChar.data.level + 1)
        updateDisplay1()
    }
    updateDisplay1(){
        GuiControl, Text, DisplayText1, % mainChar.toString()
    }
    debugClear(msg){
        GuiControl, Text, DebugWindow, % msg
    }
    print(msg){
        finalMsg := ""
        GuiControlGet, finalMsg, , DebugWindow
        finalMsg .= "`n" msg
        GuiControl, Text, DebugWindow , % finalMsg
    }
    debugPrint(msg){
        if(!currentConfig.muteDebug){
            finalMsg := ""
            GuiControlGet, finalMsg, , DebugWindow
            finalMsg .= "`n" msg
            GuiControl, Text, DebugWindow , % finalMsg
        }
    }
    trayPrint(msg){
        TrayTip, % "trayPrint", % msg
    }
    debugPrintArray(array){

        if(currentConfig.verboseDebug){
        finalMsg := ""
                GuiControlGet, finalMsg, , DebugWindow
                finalMsg .= "[ "
                for key, value in array{
                    finalMsg .= key ": " value ", "
                }
                if(array.length() > 0){
                    finalMsg := SubStr(finalMsg, 1, -2)
                }
                finalMsg .= " ]"
                GuiControl, Text, DebugWindow , % finalMsg
        }
    }
    focusGameWindow(){
        ;WinActivate, % "Tibia -"
    }
    minimizeGameWindow(){
        ;WinMinimize, % "Tibia -"
    }
    sleepForOneUpdateUnit(){
        Sleep, % currentConfig.updateRate
    }
    doSingleRotation(){
        focusGameWindow()
        Sleep % 500
        debugPrint("mainChar.data.spentMana: " mainChar.data.spentMana)
        debugPrint("mainChar.data.maxMana: " mainChar.data.maxMana)
        while ( mainChar.data.spentMana <= mainChar.data.maxMana ){
            focusGameWindow()
            for spellName, spell in mainChar.spells{
                focusGameWindow()
                mainChar.cast(spell)
                debugPrint("mainChar.data.spentMana: " mainChar.data.spentMana)
            }
            sleepForOneUpdateUnit()
            mainChar.decreaseCooldowns(currentConfig.updateRate)
        }
        mainChar.resetSpentMana()
        minimizeGameWindow()
        FormatTime, current_time, A_NowUTC, HH:mm:ss
        msg := "Last trained: " current_time "."
        if(showTrainToast){
            TrayTip, TibiaTrain, %msg%
        }
        ;GuiControl, Text, DisplayText1, % msg
        ;WinMinimize % "^(00_tibia|Remain:)"
    }
    doContinuousRotation(){
        while(!currentConfig.stop){
            doSingleRotation()
            sleepWhileNotifyingRemainingTime(mainChar.data.waitTimeBeforeStartingRotationWithLatency * 1000)
            mainChar.decreaseCooldowns(mainChar.data.waitTimeBeforeStartingRotationWithLatency * 1000)
        }
    }
    sleepWhileNotifyingRemainingTime(time_interval){
        remainingTime := time_interval
        remainingTimeInSeconds := remainingTime // 1000
        sleepTimeConstant := 10
        sleepTime := sleepTimeConstant * 1000
        keepChecking := true
        while(remainingTime >= 0){
            ;GuiControl, Text, DisplayText2, % "Remaining time: " remainingTimeInSeconds "."
            WinSetTitle, ^(00_tib|Remain:), , % "Remain: " remainingTimeInSeconds
            if (keepChecking && remainingTime <= 10000 ){
                sleepTimeConstant := 1
                sleepTime := sleepTimeConstant * 1000
                keepChecking := false
                Menu, Tray, Icon, % currentConfig.notRunningIcon
            }
            Sleep, % sleepTime
            remainingTime -= sleepTime
            remainingTimeInSeconds := remainingTime // 1000
        }
        ;Menu, Tray, Icon, % currentConfig.runningIcon
    }
    recalculateAllSpellLatencies(){
        for vocationSpellCategoryIndex, vocationSpellCategory in allSpells{
            for spellName, spell in vocationSpellCategory{
                spell.recalculateLatency()
            }
        }
        mainChar.update()
        ;for each spell
        ;    spell.recalculateLatency()
        ;global sorcererSpells := {"invisibility": invisibilitySpell, "hells core": hellsCoreSpell, "rage of the skies": rageOfTheSkiesSpell}
        ;global knightSpells := {"fierce berserk": fierceBerserkSpell, "charge": chargeSpell}
        ;global paladinSpells := {"salvation": salvationSpell, "divine caldera": divineCalderaSpell}
        ;global allSpells := [sorcererSpells, knightSpells, paladinSpells]
    }
    ;delete?
    loadConfig(){
        ;
    }
    ;delete
    zeroRadioGroup(radioGroup){
        
    }

;======================================================================================

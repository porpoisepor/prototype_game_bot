#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;! ALT
;+ SHIFT
;^ CONTROL

;TODO =================================================================================

    ; [x]TODO
    ; add currentCooldown property for each spell and each group
    ; [x]TODO
    ;    create spell classes to allow data member modification
    ; TODO
    ; create cooldown loop
    ;   test display on textbox
    ;      spell.cast() has effect of printing to screen
    ;   starts everything with 0 cooldown
    ;   every 1000ms uses hotkey for every spell with 0 cooldown && 0 cooldown in group
    ;       add full cooldown if it can be applied
    ;       for every cooldown decrease cooldown by 1000ms if cooldown >= 0
    ; TODO
    ; add GUI radio buttons, checkmarks and buttons for better control
    ;   radio buttons for vocation
    ;   checkmark for food
    ;   button for refresh
    ; TODO
    ; test sleep monitor with nc(?) cmd program
    ; TODO
    ; add paladin spells and rotation
    ; add knight spells and rotation
    ; TODO
    ; save and read necessary state from savefile
    ; TODO
    ; instead of using hotkeys, spam the full spell words for each spell

;======================================================================================
;GLOBALS ==============================================================================

    SetTitleMatchMode % 1
    reloadable := true
    global vocations := {0: "sorcerer", 1: "knight", 2: "paladin", "sorcerer": 0, "knight": 1, "paladin": 2 }
    global supportCooldown := {"type": "support", "cooldown": 1000, "currentCooldown": 0}
    global attackCooldown := {"type": "attack", "cooldown": 2000, "currentCooldown": 0}
    global slowSpellCooldown := {"type": "slowSpell", "cooldown": 4000, "currentCooldown": 0}
    global spellInvisibility := {"mana": 440, "cooldown": 1000, "currentCooldown": 0, "cooldownGroups": [supportCooldown], "words": "utana vid", "name": "invisibility"}
    global spellHellsCore := {"mana": 1100, "cooldown": 15000, "currentCooldown": 0, "cooldownGroups": [attackCooldown, slowSpellCooldown], "words": "exevo gran mas flam", "name": "hells core"}
    global spellRageOfTheSkies := {"mana": 600, "cooldown": 15000, "currentCooldown": 0, "cooldownGroups": [attackCooldown, slowSpellCooldown], "words": "exevo gran mas vis", "name": "rage of the skies"}
    global sorcererSpells := {"invisibility": spellInvisibility, "hells core": spellHellsCore, "rage of the skies": spellRageOfTheSkies}
    global printSpells := true
    global mainChar := new character
    global currentConfig := new configState
    global invisibilitySpell := new spell
    global hellsCoreSpell := new spell

;======================================================================================
;GUI LABELS ===========================================================================

    DisplayText1 :=
    DebugWindow :=
    ;debugWindow := "DebugWindow"

;======================================================================================
;CONFIG ===============================================================================

    current_dir := A_ScriptDir
    running_icon := current_dir . "\icons\running.bmp"
    not_running_icon := current_dir . "\icons\not_running.bmp"
    icons := {"running": running_icon, "not_running": not_running_icon}

;======================================================================================
;INIT =================================================================================

    ;SPELLS MUST BE INITIALIZED FIRST
    invisibilitySpell.init( "invisibility", 440, 1000, "utana vid", [supportCooldown] )
    hellsCoreSpell.init( "hells core", 1100, 15000, "exevo gran mas vis", [attackCooldown, slowSpellCooldown] )

    ;MAINCHAR DEPENDS ON SPELLS
    mainChar.init(8,vocations.sorcerer,100)

    ;CONFIG DEPENDS ON MAINCHAR
    currentConfig.init(false, mainChar)

;======================================================================================
;CLASSES ==============================================================================

    class spell{
        mana :=
        cooldown :=
        currentCooldown := 0
        words :=
        name :=
        cooldownGroups := []
        init(name, mana, cooldown, words, cooldownGroups){
            ; add cooldownGroups
            this.name := name
            this.mana := mana
            this.cooldown := cooldown
            this.words := words
            this.cooldownGroups := cooldownGroups
        }
        activateCooldowns(){
            this.currentCooldown := this.cooldown
            for cooldownGroupIndex, cooldownGroup in this.cooldownGroups{
                cooldownGroup.currentCooldown := cooldownGroup.cooldown
            }  
        }
        decreaseCooldowns(milliseconds){
            this.currentCooldown -= milliseconds
            for cooldownGroupIndex, cooldownGroup in this.cooldownGroups{
                cooldownGroup.currentCooldown -= milliseconds
            }
        }
        getCooldowns(){
            cooldowns := []
            cooldowns.push(this.currentCooldown)
            for cooldownGroupIndex, cooldownGroup in this.cooldownGroups{
                cooldowns.push(cooldownGroup.currentCooldown)
            }  
            return cooldowns
        }
        hasNoCooldown(){
            result := true
            for key, value in this.getCooldowns(){
                if (value > 0){
                    result := false
                    break
                }
            }
            return result
        }
        cast(){
            ;final effect will be Send, % {hotkey} or equivalent with sending text to the client with no keystroke delay
            debugPrint(this.name "'s cooldowns before cast: ")
            debugPrintArray(this.getCooldowns())
            if this.hasNoCooldown(){
                this.activateCooldowns()
                debugPrint(this.name " has been cast.")
            } else {
                debugPrint(this.name " has not been cast due to remaining cooldown(s).")
            }
            debugPrint(this.name "'s cooldowns after cast: ")
            debugPrintArray(this.getCooldowns())
        }
    }
    class character{
        data := {}
        spells := {}
        spellPlan := {}
        stringRepresentation := "representation not set"
        changeLevel(x){
            this.data.level := x
            this.update()
        }
        changeVocation(n){
            for key, value in vocations{
                if(n = key){
                    this.data.vocation := vocations[key]
                }
            }
            this.update()
        }
        init(level, vocation, currentMana){
            this.data.level := level
            this.updateMana(currentMana)
            this.changeVocation(vocation)
        }
        update(){
            if( this.data.vocation = vocations.0 ){
                this.data.maxMana := 30 * this.data.level - 150
                ;this.spells := sorcererSpells
                this.spells := {"invisibility": invisibilitySpell, "hells core": hellsCoreSpell}
            } else if( this.data.vocation = vocations.1 ){
                this.data.maxMana := 5 * this.data.level + 50
            } else if( this.data.vocation = vocations.2 ){
                this.data.maxMana := 15 * this.data.level - 30    
            }
            this.spellPlan := sorcererProfile.spellPlan
            this.updateRepresentation()
        }
        toString(){
            return this.stringRepresentation 
        }
        updateMana(currentMana){
            this.data.currentMana := currentMana
        }
        decreaseCooldown(spellName, milliseconds){
            this.spells[spellName].decreaseCooldowns(milliseconds)
            this.updateRepresentation()
        }
        updateRepresentation(){
            this.stringRepresentation := ""
            for key, value in this.data{
                this.stringRepresentation .= key ": " value "`n"
            }
            if(printSpells){
                for spellName, actualSpell in this.spells{
                    this.stringRepresentation .= "`t" spellName ": " actualSpell "`n"
                    for spellProperty, spellPropertyValue in actualSpell{
                        this.stringRepresentation .= "`t`t" spellProperty ": " spellPropertyValue "`n"
                        if ( spellProperty = "cooldownGroups"){
                            for cooldownGroupProperty, cooldownGroupPropertyValue in spellPropertyValue {
                                this.stringRepresentation .= "`t`t`t" cooldownGroupProperty ": " cooldownGroupPropertyValue "`n"
                                for cooldownGroupMember, cooldownGroupMemberValue in cooldownGroupPropertyValue{
                                    this.stringRepresentation .= "`t`t`t`t" cooldownGroupMember ": " cooldownGroupMemberValue "`n"
                                }
                            }
                        }
                    } 
                }
            }
            updateDisplay1()
        }
    }
    class configState{
        autoEatFood := false
        character := {}
        iconsDir := A_ScriptDir "\icons\" 
        runningIcon := this.iconsDir "running.bmp"
        notRunningIcon := this.iconsDir "not_running.bmp"
        init(autoEatFood, character){
            this.autoEatFood := autoEatFood
            this.character := character
        }
    }

;======================================================================================
;HELPERS ==============================================================================

    reloadable := true
    ^r::
        if(reloadable){
            Reload
        }
    return

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
        GuiControl, Text, debugWindow, % msg
    }
    debugPrint(msg){
        finalMsg := ""
        GuiControlGet, finalMsg, , DebugWindow
        finalMsg .= "`n" msg
        GuiControl, Text, DebugWindow , % finalMsg
    }
    trayPrint(msg){
        TrayTip, % "trayPrint", % msg
    }
    debugPrintArray(array){
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

;======================================================================================
;TESTS ================================================================================

    ^g::
        testRotations()
        TrayTip, % "Ctrl+G", "Current test ran."
    return

    ^p::
        ;debugPrint("Empty test function.")
    return
    ^i::
        invisibilitySpell.decreaseCooldowns(500)
        ;debugPrint("Empty test function.")
    return

    ^ç::
        debugClear("")
    return
    ^e::
        debugPrint(mainChar.toString())
        ;TrayTip, mainChar.toString(), % mainChar.toString()
        ;MsgBox, % mainChar.toString()
    return

    ;^+!r::
    ;return
    ^+!d::
        TrayTip, Debug info, % "No debug info."
    return
    ^+!f::
        TrayTip, % "Ctrl+Shift+F", % "No action assigned."
    return
    ^q::
        qFunc()    
    return

;======================================================================================
;MAIN =================================================================================

    qFunc(){
        Gui, font, s8, Consolas
        Gui, Add, Button, +section +w200 +r10, OK
        Gui, Add, Edit, ReadOnly vDisplayText1 +r10 +w590 +wrap +vScroll +ys, aaa
        GuiControl, Text, DisplayText1, % mainChar.toString()
        Gui, Add, Edit, ReadOnly vDebugWindow +r10 +w800 +wrap +section +xs
        ;GuiControl, Text, DebugWindow, zzz
        Gui, Show
    }

    ^+!e::
        while(!stop){
            WinRestore % "Tibia -"
            Sleep % 1000
            Send % "{F1}"
            WinMinimize % "Tibia -"
            FormatTime, current_time, A_NowUTC, HH:mm:ss
            msg := "Last trained: " . current_time . "."
            TrayTip, TibiaTrain, %msg%
            Sleep % time_interval
        }
    return

    ^+!q::
        stop := !stop
        status := stop ? "Stopped" : "Running"
        current_icon := stop ? not_running_icon : running_icon
        Menu, Tray, Icon, % current_icon
        TrayTip, % "Current Status", % status
    return

;======================================================================================
;UNIT TESTS ====================================================================

    testCheckInvisibilityCooldownMethods(){
        ;invisibilitySpell
            debugPrint("initialCooldowns with invisibilitySpell.getCooldowns(): ")
            debugPrintArray(invisibilitySpell.getCooldowns())
            debugPrint("invisibilitySpell.hasNoCooldown(): " invisibilitySpell.hasNoCooldown())
            debugPrint("invisibilitySpell.activateCooldowns(): ")
            invisibilitySpell.activateCooldowns()
            debugPrintArray(invisibilitySpell.getCooldowns())
            debugPrint("invisibilitySpell.hasNoCooldown(): " invisibilitySpell.hasNoCooldown())
            debugPrint("invisibilitySpell.decreaseCooldowns(10000): ")
            invisibilitySpell.decreaseCooldowns(10000)
            debugPrintArray(invisibilitySpell.getCooldowns())
            debugPrint("invisibilitySpell.hasNoCooldown(): " invisibilitySpell.hasNoCooldown())
        spell := invisibilitySpell
            debugPrint("initialCooldowns with spell.getCooldowns(): ")
            debugPrintArray(spell.getCooldowns())
            debugPrint("spell.hasNoCooldown(): " spell.hasNoCooldown())
            debugPrint("spell.activateCooldowns(): ")
            spell.activateCooldowns()
            debugPrintArray(spell.getCooldowns())
            debugPrint("spell.hasNoCooldown(): " spell.hasNoCooldown())
            debugPrint("spell.decreaseCooldowns(10000): ")
            spell.decreaseCooldowns(10000)
            debugPrintArray(spell.getCooldowns())
            debugPrint("spell.hasNoCooldown(): " spell.hasNoCooldown())
    }
    testCharacterSingleSpellCooldownRotation(timeInSeconds, updateRateInMilliseconds){
        spell := mainChar.spells.invisibility
        remainingTime := timeInSeconds * 1000
        checkInterval := updateRateInMilliseconds
        while(remainingTime > 0){
            spell.cast() ;already activates cooldown but only if applicable
            Sleep, % updateRateInMilliseconds
            spell.decreaseCooldowns(updateRateInMilliseconds)
            remainingTime -= updateRateInMilliseconds
        }
    }
    testCharacterMultipleSpellCooldownRotation(timeInSeconds, updateRateInMilliseconds){
        spell_1 := mainChar.spells.invisibility
        spell_2 := mainChar.spells["hells core"]
        spells := mainChar.spells
        ;spells := [spell_1, spell_2]
        remainingTime := timeInSeconds * 1000
        checkInterval := updateRateInMilliseconds
        while(remainingTime > 0){
            for spellIndex, spell in spells{
                spell.cast() ;already activates cooldown but only if applicable
                spell.decreaseCooldowns(updateRateInMilliseconds)
            }
            Sleep, % updateRateInMilliseconds
            remainingTime -= updateRateInMilliseconds
        }
    }

    testRotations(){
        ;testDurationInSeconds := 5
        ;updateRateInMilliseconds := 1000
        updateRateInMilliseconds := 500
        testDurationInSeconds := 16
        ;testCharacterSingleSpellCooldownRotation(testDurationInSeconds, updateRateInMilliseconds)
        testCharacterMultipleSpellCooldownRotation(testDurationInSeconds, updateRateInMilliseconds)
    }

;===============================================================================


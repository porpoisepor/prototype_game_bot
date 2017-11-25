#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;! ALT
;+ SHIFT
;^ CONTROL

;TODO =================================================================================
    ; CURRENT: testRotation() implementation
    ; [x]TODO
    ;   [x]add currentCooldown property for each spell and each group
    ; [x]TODO
    ;   [x]create spell classes to allow data member modification
    ; [x]TODO
    ;   [x]create cooldown loop
    ;     [x]test display on textbox
    ;        [x]spell.cast() has effect of printing to screen
    ;        [x]spell.cast() has effect of using keystroke to cast spell
    ;     [x]starts everything with 0 cooldown
    ;     [x]every X ms uses hotkey for every spell with 0 cooldown && 0 cooldown in group
    ;         [x]add full cooldown if it can be applied
    ;         [x]for every cooldown decrease cooldown by X ms ;if cooldown >= 0
    ; [x]TODO
    ;   [x]create window activation cycle
    ;       [x]check stop flag every iteration
    ;       [x]add hotkeys for each spell
    ;           [x]also add it to the cast() of each spell
    ;       [x]find out where latency should go
    ;          [x]find if it should be currentCooldown <= (0 - latency) in the mid of the rotation cycle
    ;               [x]NO, actually it should be currentCooldown := cooldown + latency in the cooldown activation()
    ;       [x]check in loop if spells should be cast every N milliseconds, N is the chosen updateRate (preferably < 200ms per udpate, > 5 per second)
    ;       [x]keep track of mana spent
    ;           [x]if spent mana >= maxMana, break out of loop and start wait(waitTime)
    ;
    ; TODO ;IMPORTANT
    ;   find out at which point globals not being in the beginning of the file matter
    ;       [x]they do matter sometimes
    ; TODO
    ;   [ ]stuff all global config inside a global configState object
    ; [ ]TODO
    ; [ ]add GUI radio buttons, checkmarks and buttons for better control
    ;   [ ]add button for printInsteafOfSendHotkey
    ;   [ ]add button for changing stop flag
    ;   [ ]radio buttons for vocation
    ;   [ ]textedit for level
    ;   [ ]checkmark for food
    ;   [ ]button for refresh
    ; TODO
    ;   move window position so it hides window when using 
    ;   add flag to control if window shall be hidden or not
    ; TODO
    ;   open tibialyzer and make it hide all health/mana bars and show only default mana bar in bottom right corner
    ; TODO
    ;   implement login
    ;      wait a few seconds before each action
    ;         get character screen position based on character list
    ;            load character profiles from savefile
    ;      consider closing ethereum miner before trying login due to impredictability of wait times
    ;         reopen miner after
    ;   implement disconnect detection based on window title (changes from "Tibia - <character_name>" to "Tibia")
    ; TODO
    ;   test sleep monitor with nircmd cmd program
    ; [x]TODO
    ;   [x]add paladin spells and rotation
    ;   [x]add knight spells and rotation
    ; TODO
    ;   save and read necessary state from savefile
    ; TODO
    ;   instead of using hotkeys, spam the full spell words for each spell
    ; [x]TODO
    ;   [x]add mana counting logic

;======================================================================================
;GLOBALS ==============================================================================
    
    
    SetTitleMatchMode, RegEx
    reloadable := true
    global vocations := { 0: "sorcerer", 1: "knight", 2: "paladin", "id": {"sorcerer": 0, "knight": 1, "paladin": 2}, "sorcerer": "sorcerer", "knight": "knight", "paladin": "paladin"}
    global serverInfo := {"sorcerer": {"manaRegen": 24}, "knight": {"manaRegen": 9}, "paladin": {"manaRegen": 16}}

    global supportCooldown := {"type": "support", "cooldown": 2000, "currentCooldown": 0}
    global healingCooldown := {"type": "healing", "cooldown": 1000, "currentCooldown": 0}
    global attackCooldown := {"type": "attack", "cooldown": 2000, "currentCooldown": 0}
    global slowSpellCooldown := {"type": "slowSpell", "cooldown": 4000, "currentCooldown": 0}
    
    global printSpells := true
    global mainChar := new character
    global currentConfig := new configState
    
    ;sorcerer spells
    global invisibilitySpell := new spell
    global hellsCoreSpell := new spell
    global rageOfTheSkiesSpell := new spell
    ;knight spells
    global fierceBerserkSpell := new spell
    global chargeSpell := new spell
    ;paladin spells
    global salvationSpell := new spell    
    global divineCalderaSpell := new spell

    ;global config
    global latency := 300 ;ms
    global updateRate := 190 ;ms
    global printInsteadOfSendHotkey := true
    global stop := false
    global considerLatency := false
    global verboseDebug := true
    
    ;vocation spells
    global sorcererSpells := {"invisibility": invisibilitySpell, "hells core": hellsCoreSpell, "rage of the skies": rageOfTheSkiesSpell}
    global knightSpells := {"fierce berserk": fierceBerserkSpell, "charge": chargeSpell}
    global paladinSpells := {"salvation": salvationSpell, "divine caldera": divineCalderaSpell}
    global allSpells := [sorcererSpells, knightSpells, paladinSpells]

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
    ;sorcerer
        invisibilitySpell.init( "invisibility", 440, 2000 , "utana vid", [supportCooldown], "{F1}" )
        hellsCoreSpell.init( "hells core", 1100, 15000 , "exevo gran mas flam", [attackCooldown, slowSpellCooldown], "{F3}" )
        rageOfTheSkiesSpell.init( "rage of the skies", 600, 15000 , "exevo gran mas vis", [attackCooldown, slowSpellCooldown], "{F4}" )
    ;knight
        fierceBerserkSpell.init( "fierce berserk", 340, 6000 , "exori gran", [attackCooldown], "{F3}" )
        chargeSpell.init( "charge", 100, 2000 , "utani tempo hur", [supportCooldown], "{F1}" )
    ;paladin
        salvationSpell.init( "salvation", 210, 1000 , "exura gran san", [healingCooldown], "{F1}" )
        divineCalderaSpell.init( "divine caldera", 160, 2000 , "exevo mas san", [attackCooldown], "{F3}" )

    ;MAINCHAR DEPENDS ON SPELLS
    ;mainChar.init(160, vocations.sorcerer, 100)
    ;mainChar.init(80, vocations.knight, 100)
    ;mainChar.init(120, vocations.paladin, 100)
    mainChar.init(30, vocations.paladin, 100)

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
        manaConsumptionPerSec := 1
        manaConsumptionPerSecWithLatency := 1
        hotkey := ""

        init(name, mana, cooldown, words, cooldownGroups, hotkey){
            this.name := name
            this.mana := mana
            this.cooldown := cooldown
            this.words := words
            this.cooldownGroups := cooldownGroups
            this.manaConsumptionPerSec := this.mana * 1000 / this.cooldown
            this.manaConsumptionPerSecWithLatency := this.mana * 1000 / (this.cooldown + latency)
            this.hotkey := hotkey
        }
        activateCooldowns(){
            this.currentCooldown := this.cooldown + latency
            for cooldownGroupIndex, cooldownGroup in this.cooldownGroups{
                cooldownGroup.currentCooldown := cooldownGroup.cooldown + latency
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
            castSuccessful := false
            debugPrint(this.name "'s cooldowns before cast: ")
            debugPrintArray(this.getCooldowns())
            if this.hasNoCooldown(){
                this.activateCooldowns()
                debugPrint(this.name " has been cast.")
                castSuccessful := true
                if(printInsteadOfSendHotkey){
                    debugPrint(this.hotkey " has been pressed.")
                } else {
                    Send, % this.hotkey
                }
            } else {
                debugPrint(this.name " has not been cast due to remaining cooldown(s).")
            }
            debugPrint(this.name "'s cooldowns after cast: ")
            debugPrintArray(this.getCooldowns())
            return castSuccessful
        }
    }
    class character{
        data := {}
        spells := {}
        stringRepresentation := "representation not set"
        changeLevel(x){
            this.data.level := x
            this.update()
        }
        changeVocation(vocation){
            for key, value in vocations{
                if(vocation = key){
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
            if( this.data.vocation = vocations.sorcerer ){
                this.data.maxMana := 30 * this.data.level - 150
                this.data.autoattackManaPerSec := 11.3
                this.spells := sorcererSpells
            } else if( this.data.vocation = vocations.knight ){
                this.data.maxMana := 5 * this.data.level + 50
                this.data.autoattackManaPerSec := 0
                this.spells := knightSpells
            } else if( this.data.vocation = vocations.paladin ){
                this.data.maxMana := 15 * this.data.level - 30
                this.data.autoattackManaPerSec := 0
                this.spells := paladinSpells
            }
            this.data.spentMana := 0
            this.data.manaRegen := serverInfo[this.data.vocation].manaRegen
            this.updateManaConsumption()
            this.updateRotationTime()
            this.updateRepresentation()
        }
        cast(spell){
            castSuccessful := spell.cast()
            if (castSuccessful){
                this.data.spentMana += spell.mana
            }
        }
        resetSpentMana(){
            this.data.spentMana := 0
        }
        toString(){
            return this.stringRepresentation 
        }
        updateManaConsumption(){
            rotationConsumptionPerSec := 0
            rotationConsumptionPerSecWithLatency := 0
            for spellName, spell in this.spells{
                rotationConsumptionPerSec += spell.manaConsumptionPerSec
                rotationConsumptionPerSecWithLatency += spell.manaConsumptionPerSecWithLatency
            }
            this.data.rotationConsumptionPerSec := rotationConsumptionPerSec
            this.data.rotationConsumptionPerSecWithLatency := rotationConsumptionPerSecWithLatency
        }
        updateRotationTime(){
            ;wait time before starting rotation = time for full - time for consumption
            this.data.timeForFullMana := this.data.maxMana / (this.data.manaRegen - this.data.autoattackManaPerSec)
            this.data.timeForFullManaConsumption := this.data.maxMana / this.data.rotationConsumptionPerSec
            this.data.timeForFullManaConsumptionWithLatency := this.data.maxMana / this.data.rotationConsumptionPerSecWithLatency
            this.data.waitTimeBeforeStartingRotation := this.data.timeForFullMana - this.data.timeForFullManaConsumption
            this.data.waitTimeBeforeStartingRotationWithLatency := this.data.timeForFullMana - this.data.timeForFullManaConsumptionWithLatency
        }
        updateMana(currentMana){
            this.data.currentMana := currentMana
        }
        decreaseCooldowns(milliseconds){
            for spellName, spell in this.spells{
                spell.decreaseCooldowns(milliseconds)
            }
            this.updateRepresentation()
            ;this.spells[spellName].decreaseCooldowns(milliseconds)
            ;this.updateRepresentation()
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
    ;use configState.updateState for passing state from the GUI to the character
    class configState{
        autoEatFood := false
        character := {}
        vocation :=
        iconsDir := A_ScriptDir "\icons\" 
        runningIcon := this.iconsDir "running.bmp"
        notRunningIcon := this.iconsDir "not_running.bmp"
        init(autoEatFood, character){
            this.autoEatFood := autoEatFood
            this.character := character
        }
        updateState(vocation, level){
            mainChar.init(level, vocation, 0)
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
        if(verboseDebug){
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

        if(verboseDebug){
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
        Sleep, % updateRate
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
            mainChar.decreaseCooldowns(updateRate)
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
        while(!stop){
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
                Menu, Tray, Icon, % icons.not_running
            }
            Sleep, % sleepTime
            remainingTime -= sleepTime
            remainingTimeInSeconds := remainingTime // 1000
        }
        ;Menu, Tray, Icon, % icons.running
    }


;======================================================================================
;TESTS ================================================================================

    ^g::
        testRotation()
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
    testMockCharacterSingleSpellCooldownRotation(timeInSeconds, updateRateInMilliseconds){
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
    testMockCharacterMultipleSpellCooldownRotation(timeInSeconds, updateRateInMilliseconds){
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
    testMockRotations(){
        ;testDurationInSeconds := 5
        ;updateRateInMilliseconds := 1000
        updateRateInMilliseconds := 500
        testDurationInSeconds := 6
        ;testMockCharacterSingleSpellCooldownRotation(testDurationInSeconds, updateRateInMilliseconds)
        testMockCharacterMultipleSpellCooldownRotation(testDurationInSeconds, updateRateInMilliseconds)
    }
    testRotation(){
        ; [x]TODO   
        ;   [x]create window activation cycle
        ;       [x]check stop flag every iteration
        ;       [x]add hotkeys for each spell
        ;           [x]also add it to the cast() of each spell
        ;       [x]find out where latency should go
        ;          [x]find if it should be currentCooldown <= (0 - latency) in the mid of the rotation cycle
        ;               [x]NO, actually it should be currentCooldown := cooldown + latency in the cooldown activation()
        ;       [x]check in loop if spells should be cast every N milliseconds, N is the chosen updateRate (preferably < 200ms per udpate, > 5 per second)
        ;       [x]keep track of mana spent
        ;           [x]if spent mana >= maxMana, break out of loop and start wait(waitTime)

        ; [x]doContinuousRotation()
        ;   [x]do multiple single rotations
        ;   [x]check stop flag every iteration
        ; [x]doSingleRotation()
        ;   [x]keep rotating until spentMana >= maxMana
        ;   [x]after that, sleep (while notifying GUI of remaining time)
        ;doSingleRotation()
        doContinuousRotation()
    }


;===============================================================================

;SYNTAX TESTS ==================================================================

    class someSpell{
        mana := 200
        cooldown := 2000
        manaPerSec := this.mana / this.cooldown * 1000
    }
    manaPerSec(){
        aSpell := new someSpell
        debugPrint("aSpell.manaPerSec: " aSpell.manaPerSec )
        debugPrint("aSpell.manaPerSec: " aSpell["manaPerSec"] )
        ;debugPrint("someSpell.manaPerSec: " someSpell.manaPerSec )
    }

;===============================================================================

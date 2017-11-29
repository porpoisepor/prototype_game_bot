;CLASSES ==============================================================================

    class configState{
        iconsDir := A_ScriptDir "\icons\" 
        runningIcon := this.iconsDir "running.bmp"
        notRunningIcon := this.iconsDir "not_running.bmp"
        iniFile := A_ScriptDir "\ini_files\main_ini.ini"
        iniMainSection := "mainSection"
        ;moved here
        latency := 300 ;ms
        updateRate := 1200 ;ms
        printInsteadOfSendHotkey := false
        stop := false
        muteDebug := false
        copyInputFromGameToScreen := true
        reloadable := true
        printSpells := true
        level := 10
        vocation := "vocation not set"
        verboseDebug := false
        init(){
            
        }
        updateStateFromGUI(){
            ;get GUI values
            allCallbacks()
        }
        saveStateFromGUIToIniFile(){
            this.updateStateFromGUI()
            for propertyName, propertyValue in this{
                debugPrint("currentConfig.propertyName, currentConfig.propertyValue: " propertyName ", " propertyValue )
                IniWrite, % propertyValue, % this.iniFile, % this.iniMainSection, % propertyName
            }
        }
        loadStateToGUI(){
            
        }
        printState(){
            debugClear("")  
            for propertyName, propertyValue in this{
                debugPrint("currentConfig.propertyName, currentConfig.propertyValue: " propertyName ", " propertyValue )
            }
        }
        loadStateFromIniFile(){
            printLocal := false
            iniContents :=
            IniRead, iniContents, % this.iniFile, % this.iniMainSection
            if(printLocal){
                debugClear("")
                debugPrint("Full iniContents:`n" iniContents)
            }
            lines := StrSplit(iniContents, "`n")
            if(printLocal){
                ;debugPrint("`nSplit lines at iniContents: ")
            }
            for lineIndex, line in lines{
                keyAndValue := StrSplit(line, "=")
                key := keyAndValue[1]
                value := keyAndValue[2]
                this[key] := value
                if(printLocal){
                    ;debugPrint(line)
                    ;debugPrint("Key, value: " key ", " value)
                }
            }
            ;this.printState()
        }
    }

;======================================================================================

;CLASSES ==============================================================================

    class configState{
        iconsDir := A_ScriptDir "\icons\" 
        runningIcon := this.iconsDir "running.bmp"
        notRunningIcon := this.iconsDir "not_running.bmp"
        icons := {"running": running_icon, "not_running": not_running_icon}
        ;moved here
        latency := 300 ;ms
        updateRate := 190 ;ms
        printInsteadOfSendHotkey := false
        stop := false
        muteDebug := false
        copyInputFromGameToScreen := true
        reloadable := true
        printSpells := true
        init(){
            
        }
    }

;======================================================================================

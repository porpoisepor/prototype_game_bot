;HOTKEYS ================================================================================

    ^g::
        testRotation()
        TrayTip, % "Ctrl+G", "Current test ran."
    return

    ^ç::
        debugClear("")
    return

    ^e::
        debugPrint(mainChar.toString())
        ;TrayTip, mainChar.toString(), % mainChar.toString()
        ;MsgBox, % mainChar.toString()
    return

    ^q::
        qFunc()    
    return

    ^r::
        if(reloadable){
            Reload
        }
    return
    
/*=UNUSED HOTKEYS======================================================================

    ^p::
        ;debugPrint("Empty test function.")
    return

    ^i::
        invisibilitySpell.decreaseCooldowns(500)
        ;debugPrint("Empty test function.")
    return
    
    ^+!r::
    return
    
    ^+!d::
        TrayTip, Debug info, % "No debug info."
    return
    
    ^+!f::
        TrayTip, % "Ctrl+Shift+F", % "No action assigned."
    return

    ;legacy
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

    ;legacy
    ^+!q::
        stop := !stop
        status := stop ? "Stopped" : "Running"
        current_icon := stop ? not_running_icon : running_icon
        Menu, Tray, Icon, % current_icon
        TrayTip, % "Current Status", % status
    return
    
*/=====================================================================================

;======================================================================================
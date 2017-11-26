;CLASSES ==============================================================================

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

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
        recalculateLatency(){
            this.manaConsumptionPerSecWithLatency := this.mana * 1000 / (this.cooldown + latency)
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
                    if(copyInputFromGameToScreen){
                        print(this.hotkey " has been pressed.")
                    }
                }
            } else {
                debugPrint(this.name " has not been cast due to remaining cooldown(s).")
            }
            debugPrint(this.name "'s cooldowns after cast: ")
            debugPrintArray(this.getCooldowns())
            return castSuccessful
        }
    }

;======================================================================================

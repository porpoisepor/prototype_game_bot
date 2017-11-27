;CLASSES ==============================================================================

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
            if(currentConfig.printSpells){
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

;======================================================================================

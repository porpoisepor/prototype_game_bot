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

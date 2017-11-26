;GLOBALS ==============================================================================
    SetTitleMatchMode, RegEx
    reloadable := true
    global vocations := { 0: "sorcerer", 1: "knight", 2: "paladin", "id": {"sorcerer": 0, "knight": 1, "paladin": 2}, "sorcerer": "sorcerer", "knight": "knight", "paladin": "paladin"}
    global serverInfo := {"sorcerer": {"manaRegen": 24}, "knight": {"manaRegen": 9}, "paladin": {"manaRegen": 16}}

    global supportCooldown := {"type": "support", "cooldown": 2000, "currentCooldown": 0}
    global healingCooldown := {"type": "healing", "cooldown": 1000, "currentCooldown": 0}
    global attackCooldown := {"type": "attack", "cooldown": 2000, "currentCooldown": 0}
    global slowSpellCooldown := {"type": "slowSpell", "cooldown": 4000, "currentCooldown": 0}
    global foodCooldown := {"type": "food", "cooldown": 1000, "currentCooldown": 0}
    
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
    global brownMushroomSpell := new spell

    ;global config
    global latency := 300 ;ms
    global updateRate := 190 ;ms
    global printInsteadOfSendHotkey := false
    global stop := false
    global considerLatency := false
    global muteDebug := false
    global copyInputFromGameToScreen := true
    global reloadable := true
    
    ;vocation spells
    global sorcererSpells := {"invisibility": invisibilitySpell, "hells core": hellsCoreSpell, "rage of the skies": rageOfTheSkiesSpell, "brown mushroom": brownMushroomSpell}
    global knightSpells := {"fierce berserk": fierceBerserkSpell, "charge": chargeSpell, "brown mushroom": brownMushroomSpell}
    global paladinSpells := {"salvation": salvationSpell, "divine caldera": divineCalderaSpell, "brown mushroom": brownMushroomSpell}
    global allSpells := [sorcererSpells, knightSpells, paladinSpells]

;======================================================================================
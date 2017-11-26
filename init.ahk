;INIT =================================================================================

    ;LATER OBJECTS DEPEND ON SOME GLOBAL CONFIGURATION SUCH AS LATENCY
    currentConfig.init()

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
    ;food
        brownMushroomSpell.init( "brown mushroom", 0, 264000 , "", [foodCooldown], "{F2}" )

    ;MAINCHAR DEPENDS ON SPELLS
    ;mainChar.init(160, vocations.sorcerer, 100)
    ;mainChar.init(80, vocations.knight, 100)
    ;mainChar.init(120, vocations.paladin, 100)
    mainChar.init(30, vocations.paladin, 100)


;======================================================================================
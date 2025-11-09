local rolls = {}

rolls.IDs = T {
    [98] = 'Fighter\'s Roll',
    [99] = 'Monk\'s Roll',
    [100] = 'Healer\'s Roll',
    [101] = 'Wizard\'s Roll',
    [102] = 'Warlock\'s Roll',
    [103] = 'Rogue\'s Roll',
    [104] = 'Gallant\'s Roll',
    [105] = 'Chaos Roll',
    [106] = 'Beast Roll',
    [107] = 'Choral Roll',
    [108] = 'Hunter\'s Roll',
    [109] = 'Samurai Roll',
    [110] = 'Ninja Roll',
    [111] = 'Drachen Roll',
    [112] = 'Evoker\'s Roll',
    [113] = 'Magus\'s Roll',
    [114] = 'Corsair\'s Roll',
    [115] = 'Puppet Roll',
    [116] = 'Dancer\'s Roll',
    [117] = 'Scholar\'s Roll',
    [118] = 'Bolter\'s Roll',
    [119] = 'Caster\'s Roll',
    [120] = 'Courser\'s Roll',
    [121] = 'Blitzer\'s Roll',
    [122] = 'Tactician\'s Roll',
    [302] = 'Allies\' Roll',
    [303] = 'Miser\'s Roll',
    [304] = 'Companion\'s Roll',
    [305] = 'Avenger\'s Roll',
    [390] = 'Naturalist\'s Roll',
    [391] = 'Runeist\'s Roll',
}

rolls.unlockLevel = {
    [98] = 5,    -- Corsair's Roll
    [99] = 5,    -- Ninja Roll
    [100] = 8,   -- Hunter's Roll
    [101] = 14,  -- Chaos Roll
    [102] = 17,  -- Magician's Roll
    [103] = 20,  -- Healer's Roll
    [104] = 23,  -- Drachen Roll
    [105] = 26,  -- Choral Roll
    [106] = 32,  -- Monk's Roll
    [107] = 35,  -- Beast Roll
    [108] = 38,  -- Samurai Roll
    [109] = 41,  -- Evoker's Roll
    [110] = 44,  -- Rogue's Roll
    [111] = 47,  -- Warlock's Roll
    [112] = 50,  -- Fighter's Roll
    [113] = 55,  -- Puppet Roll
    [114] = 58,  -- Gallant's Roll
    [115] = 61,  -- Wizard's Roll
    [116] = 64,  -- Dancer's Roll
    [117] = 67,  -- Scholar's Roll
    [118] = 70,  -- Naturalist's Roll
    [119] = 75,  -- Runeist's Roll
    [120] = 40,  -- Bolter's Roll
    [121] = 45,  -- Caster's Roll
    [122] = 52,  -- Courser's Roll
    [303] = 88,  -- Blitzer's Roll
    [302] = 91,  -- Tactician's Roll
    [301] = 94   -- Allies' Roll
}

rolls.buffs = {
    [98] = 310,  -- Fighter's Roll
    [99] = 311,  -- Monk's Roll
    [100] = 312, -- Healer's Roll
    [101] = 313, -- Wizard's Roll
    [102] = 314, -- Warlock's Roll
    [103] = 315, -- Rogue's Roll
    [104] = 316, -- Gallant's Roll
    [105] = 317, -- Chaos Roll
    [106] = 318, -- Beast Roll
    [107] = 319, -- Choral Roll
    [108] = 320, -- Hunter's Roll
    [109] = 321, -- Samurai's Roll
    [110] = 322, -- Ninja's Roll
    [111] = 323, -- Drachen's Roll
    [112] = 324, -- Evoker's Roll
    [113] = 325, -- Magus's Roll
    [114] = 326, -- Corsair's Roll
    [115] = 327, -- Puppet's Roll
    [116] = 328, -- Dancer's Roll
    [117] = 329, -- Scholar's Roll
    [118] = 330, -- Bolter's Roll
    [119] = 331, -- Caster's Roll
    [120] = 332, -- Courser's Roll
    [121] = 333, -- Blitzer's Roll
    [122] = 334, -- Tactician's Roll
    [302] = 335, -- Allies' Roll
    [303] = 336, -- Miser's Roll
    [304] = 337, -- Companion's Roll
    [305] = 338, -- Avenger's Roll
    [390] = 339, -- Naturalist's Roll
    [391] = 600  -- Runeist's Roll
}

rolls.corsairRoll_Data = {
    ['Corsair\'s Roll'] = {
        ['lucky'] = 5,
        ['unlucky'] = 9,
        ['rolls'] = {10, 11, 11, 12, 20, 13, 15, 16, 8, 17, 24},
        ['effect'] = 2,
        ['bust'] = 6,
        ['desc'] = 'Experience / Capacity Points'
    },
    ['Ninja Roll'] = {
        ['lucky'] = 4,
        ['unlucky'] = 8,
        ['rolls'] = {4, 6, 8, 25, 10, 12, 14, 2, 17, 20, 30},
        ['effect'] = 2,
        ['bust'] = 10,
        ['desc'] = 'Evasion'
    },
    ['Hunter\'s Roll'] = {
        ['lucky'] = 4,
        ['unlucky'] = 8,
        ['rolls'] = {10, 13, 15, 40, 18, 20, 25, 5, 27, 30, 50},
        ['effect'] = 5,
        ['bust'] = 15,
        ['desc'] = 'Accuracy'
    },
    ['Chaos Roll'] = {
        ['lucky'] = 4,
        ['unlucky'] = 8,
        ['rolls'] = {6.3, 7.8, 9.4, 25, 10.9, 12.5, 15.6, 3.1, 17.2, 18.8, 31.2},
        ['effect'] = 3,
        ['bust'] = 10,
        ['desc'] = 'Attack'
    },
    ['Magus\'s Roll'] = {
        ['lucky'] = 2,
        ['unlucky'] = 6,
        ['rolls'] = {5, 20, 6, 8, 9, 3, 10, 13, 14, 15, 25},
        ['effect'] = 2,
        ['bust'] = 8,
        ['desc'] = 'Magic Defense Bonus'
    },
    ['Healer\'s Roll'] = {
        ['lucky'] = 3,
        ['unlucky'] = 7,
        ['rolls'] = {3, 4, 12, 5, 6, 7, 1, 8, 9, 10, 16},
        ['effect'] = 3,
        ['bust'] = 4,
        ['desc'] = 'Cure Potency'
    },
    ['Drachen Roll'] = {
        ['lucky'] = 4,
        ['unlucky'] = 8,
        ['rolls'] = {10, 13, 15, 40, 18, 20, 25, 5, 28, 30, 50},
        ['effect'] = 5,
        ['bust'] = 15,
        ['desc'] = 'Pet: Accuracy / Ranged Accuracy'
    },
    ['Choral Roll'] = {
        ['lucky'] = 2,
        ['unlucky'] = 6,
        ['rolls'] = {8, 42, 11, 15, 19, 4, 23, 27, 31, 35, 50},
        ['effect'] = 4,
        ['bust'] = 25,
        ['desc'] = 'Spell Interruption Rate down'
    },
    ['Monk\'s Roll'] = {
        ['lucky'] = 3,
        ['unlucky'] = 7,
        ['rolls'] = {8, 10, 32, 12, 14, 16, 4, 20, 22, 24, 40},
        ['effect'] = 5,
        ['bust'] = 10,
        ['desc'] = 'Subtle Blow'
    },
    ['Beast Roll'] = {
        ['lucky'] = 4,
        ['unlucky'] = 8,
        ['rolls'] = {6, 8, 9, 25, 11, 13, 16, 3, 17, 19, 31},
        ['effect'] = 3,
        ['bust'] = 10,
        ['desc'] = 'Pet: Attack / Ranged Attack'
    },
    ['Samurai Roll'] = {
        ['lucky'] = 2,
        ['unlucky'] = 6,
        ['rolls'] = {8, 32, 10, 12, 14, 4, 16, 20, 22, 24, 40},
        ['effect'] = 4,
        ['bust'] = 10,
        ['desc'] = 'Store TP'
    },
    ['Evoker\'s Roll'] = {
        ['lucky'] = 5,
        ['unlucky'] = 9,
        ['rolls'] = {1, 1, 1, 1, 3, 2, 2, 2, 1, 3, 4},
        ['effect'] = 1,
        ['bust'] = 'Unknown',
        ['desc'] = 'Refresh'
    },
    ['Rogue\'s Roll'] = {
        ['lucky'] = 5,
        ['unlucky'] = 9,
        ['rolls'] = {1, 2, 3, 4, 10, 5, 6, 7, 1, 8, 14},
        ['effect'] = 1,
        ['bust'] = 5,
        ['desc'] = 'Critical Hite Rate'
    },
    ['Warlock\'s Roll'] = {
        ['lucky'] = 4,
        ['unlucky'] = 8,
        ['rolls'] = {2, 3, 4, 12, 5, 6, 7, 1, 8, 9, 15},
        ['effect'] = 1,
        ['bust'] = 5,
        ['desc'] = 'Magic Accuracy'
    },
    ['Fighter\'s Roll'] = {
        ['lucky'] = 5,
        ['unlucky'] = 9,
        ['rolls'] = {1, 2, 3, 4, 10, 5, 6, 6, 1, 7, 15},
        ['effect'] = 1,
        ['bust'] = 'Unknown',
        ['desc'] = 'Double Attack'
    },
    ['Puppet Roll'] = {
        ['lucky'] = 3,
        ['unlucky'] = 7,
        ['rolls'] = {5, 8, 35, 11, 14, 18, 2, 22, 26, 30, 40},
        ['effect'] = 3,
        ['bust'] = 12,
        ['desc'] = 'Pet: Magic Accuracy / Magic Attack Bonus'
    },
    ['Gallant\'s Roll'] = {
        ['lucky'] = 3,
        ['unlucky'] = 7,
        ['rolls'] = {4.69, 5.86, 19.53, 7.03, 8.59, 10.16, 3.13, 11.72, 13.67, 15.63, 23.44},
        ['effect'] = 2.34,
        ['bust'] = '-11.72',
        ['desc'] = 'Defense'
    },
    ['Wizard\'s Roll'] = {
        ['lucky'] = 5,
        ['unlucky'] = 9,
        ['rolls'] = {4, 6, 8, 10, 25, 12, 14, 17, 2, 20, 30},
        ['effect'] = 2,
        ['bust'] = 10,
        ['desc'] = 'Magic Attack Bonus'
    },
    ['Dancer\'s Roll'] = {
        ['lucky'] = 3,
        ['unlucky'] = 7,
        ['rolls'] = {3, 4, 12, 5, 6, 7, 1, 8, 9, 10, 16},
        ['effect'] = 2,
        ['bust'] = 4,
        ['desc'] = 'Regen'
    },
    ['Scholar\'s Roll'] = {
        ['lucky'] = 2,
        ['unlucky'] = 6,
        ['rolls'] = {2, 10, 3, 4, 4, 1, 5, 6, 7, 7, 12},
        ['effect'] = 'Unknown',
        ['bust'] = 3,
        ['desc'] = 'Conserve MP'
    },
    ['Naturalist\'s Roll'] = {
        ['lucky'] = 3,
        ['unlucky'] = 7,
        ['rolls'] = {6, 7, 15, 8, 9, 10, 5, 11, 12, 13, 20},
        ['effect'] = 1,
        ['bust'] = 5,
        ['desc'] = 'Enhancing Magic Duration'
    },
    ['Runeist\'s Roll'] = {
        ['lucky'] = 4,
        ['unlucky'] = 8,
        ['rolls'] = {4, 6, 8, 25, 10, 12, 14, 2, 17, 20, 30},
        ['effect'] = 2,
        ['bust'] = 10,
        ['desc'] = 'Magic Evasion'
    },
    ['Bolter\'s Roll'] = {
        ['lucky'] = 3,
        ['unlucky'] = 9,
        ['rolls'] = {6, 6, 16, 8, 8, 10, 10, 12, 4, 14, 20},
        ['effect'] = 4,
        ['bust'] = 0,
        ['desc'] = 'Movement Speed'
    },
    ['Caster\'s Roll'] = {
        ['lucky'] = 2,
        ['unlucky'] = 7,
        ['rolls'] = {6, 15, 7, 8, 9, 10, 5, 11, 12, 13, 20},
        ['effect'] = 3,
        ['bust'] = 10,
        ['desc'] = 'Fast Cast'
    },
    ['Courser\'s Roll'] = {
        ['lucky'] = 3,
        ['unlucky'] = 9,
        ['rolls'] = {'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown'},
        ['effect'] = 'Unknown',
        ['bust'] = 'Unknown',
        ['desc'] = 'Snapshot'
    },
    ['Blitzer\'s Roll'] = {
        ['lucky'] = 4,
        ['unlucky'] = 9,
        ['rolls'] = {2, 3, 4, 11, 5, 6, 7, 8, 1, 10, 12},
        ['effect'] = 1,
        ['bust'] = 'Unknown',
        ['desc'] = 'Haste'
    },
    ['Tactician\'s Roll'] = {
        ['lucky'] = 5,
        ['unlucky'] = 8,
        ['rolls'] = {10, 10, 10, 10, 30, 10, 10, 0, 20, 20, 40},
        ['effect'] = 2,
        ['bust'] = 10,
        ['desc'] = 'Regain'
    },
    ['Allies\' Roll'] = {
        ['lucky'] = 3,
        ['unlucky'] = 10,
        ['rolls'] = {2, 3, 20, 5, 7, 9, 11, 13, 15, 1, 25},
        ['effect'] = 1,
        ['bust'] = 5,
        ['desc'] = 'Skillchan Damage / Accuracy'
    },
    ['Miser\'s Roll'] = {
        ['lucky'] = 5,
        ['unlucky'] = 7,
        ['rolls'] = {30, 50, 70, 90, 200, 110, 20, 130, 150, 170, 250},
        ['effect'] = 15,
        ['bust'] = 0,
        ['desc'] = 'Save TP'
    },
    ['Avenger\'s Roll'] = {
        ['lucky'] = 4,
        ['unlucky'] = 8,
        ['rolls'] = {'Unknown', 'Unknown', 'Unknown', 14, 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 16},
        ['effect'] = 'Unknown',
        ['bust'] = 'Unknown',
        ['desc'] = 'Counter Rate'
    },
    ['Companion\'s Roll'] = {
        ['lucky'] = 2,
        ['unlucky'] = 10,
        ['rolls'] = {'20,4', '50,20', '20,6', '20,8', '30,10', '30,12', '30,14', '40,16', '40,18', '10,3', '60,25'},
        ['effect'] = '5,2',
        ['bust'] = '0,0',
        ['desc'] = 'Pet: Regain / Regen'
    },
}

-- Roll enhancement gear data
rolls.gearData = {
    -- Neck slot equipment
    neck = {
        [26038] = { phantomRoll = 7, name = 'Regal Necklace' }
    },
    -- Ring slot equipment
    ring = {
        [28548] = { phantomRoll = 5, name = 'Barataria Ring' },
        [28547] = { phantomRoll = 3, name = 'Merirosvo Ring' },
    },
    mainhand = {
        [21579] = { augmented = true, name = 'Comm. Knife' },
        [21580] = { augmented = true, name = 'Lanun Knife' },
        [21581] = { augmented = true, name = 'Rostam' },
    },
}

rolls.rankAugmentPhantomRoll = {
    [1] = 0,  -- No bonus
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
    [9] = 0,
    [10] = 0,
    [11] = 0,
    [12] = 0,
    [13] = 0,
    [14] = 5,  -- "Phantom Roll"+5
    [15] = 6,  -- "Phantom Roll"+6
    [16] = 6,  -- "Phantom Roll"+6
    [17] = 6,  -- "Phantom Roll"+6
    [18] = 6,  -- "Phantom Roll"+6
    [19] = 6,  -- "Phantom Roll"+6
    [20] = 7,  -- "Phantom Roll"+7
    [21] = 7,  -- "Phantom Roll"+7
    [22] = 7,  -- "Phantom Roll"+7
    [23] = 7,  -- "Phantom Roll"+7
    [24] = 7,  -- "Phantom Roll"+7
    [25] = 7,  -- "Phantom Roll"+7
    [26] = 7,  -- "Phantom Roll"+7
    [27] = 7,  -- "Phantom Roll"+7
    [28] = 7,  -- "Phantom Roll"+7
    [29] = 7,  -- "Phantom Roll"+7
    [30] = 8,  -- "Phantom Roll"+8 (maximum)
}

return rolls
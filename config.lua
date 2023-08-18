return {
    debug = {poly = false, treasures = true},   -- true to see marker above treasures and poly zones

    treasures = {
        count = 100, -- limit of number of treasures that spawns in area
        close = 2, -- close range to dig
        distance = 6, -- distance to start the BEEP sound away from treasure center
    },

    detector = {
        overheat = 86, -- value which detector will damaged
        heat = 80, -- value which notify start warning you that detector is over heating, if the value passed the 'overheat' value the detector will damage
    },

    detectZones = {
        {
            vector3(-1122.23, -1698.69, 0.0),
            vector3(-1198.77, -1832.57, 0.0),
            vector3(-1229.61, -1855.9927978516, 0.0),
            vector3(-1230.87, -1767.28, 0.0),
            vector3(-1261.4217529297, -1830.6840820312, 0.0),
            vector3(-1612.1901855469, -1141.1480712891, 0.0),
            vector3(-1586.1876220703, -1071.6724853516, 0.0),
            vector3(-1422.1868896484, -1110.5142822266, 0.0),
            vector3(-1405.5825195312, -1395.3377685547, 0.0),
            vector3(-1323.0729980469, -1605.9655761719, 0.0)
        },
        {
            vector3(-1679.6752929688, -981.88470458984, 0.0),
            vector3(-1679.6752929688, -981.88470458984, 0.0),
            vector3(-1717.31640625, -1063.8728027344, 0.0),
            vector3(-2113.6811523438, -554.88806152344, 0.0),
            vector3(-2057.0686035156, -503.62591552734, 0.0),
            vector3(-1848.9615478516, -657.43768310547, 0.0),
            vector3(-1752.3885498047, -741.12536621094, 0.0),
            vector3(-1729.9864501953, -918.60015869141, 0.0)
        },
        {
            vector3(-1075.5496826172, -145.32153320312, 0.0),
            vector3(-1324.7716064453, 23.515180587769, 0.0),
            vector3(-1338.4162597656, 183.1936340332, 0.0),
            vector3(-1109.5949707031, 219.35273742676, 0.0),
            vector3(-975.8134765625, -25.266059875488, 0.0)
        },
    },
}

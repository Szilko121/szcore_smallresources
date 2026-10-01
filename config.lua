SzCoreSmallConfig = {
    crouch = true,
    cruise = true,
    noSeatShuffle = true,
    tackle = true,
    tackleDistance = 2.1,
    stunGroundTimeMs = 6500,
    vehiclePush = true,
    flipVehicle = true,
    weaponDrawAnimation = true,
    infiniteUtilityAmmo = true,
    consumables = true,
    recoil = {
        enabled = true,
        default = 0.08,
        weapons = {
            [joaat('WEAPON_PISTOL')]=0.10,[joaat('WEAPON_COMBATPISTOL')]=0.10,[joaat('WEAPON_APPISTOL')]=0.16,[joaat('WEAPON_SMG')]=0.13,
            [joaat('WEAPON_ASSAULTRIFLE')]=0.18,[joaat('WEAPON_CARBINERIFLE')]=0.15,[joaat('WEAPON_PUMPSHOTGUN')]=0.28,[joaat('WEAPON_SNIPERRIFLE')]=0.45,
        }
    },
    teleports = {}, -- { {from=vector3(...),to=vector4(...),label='Lift'} }
}

local C=SzCoreSmallConfig
local crouched=false;local cruiseVeh=0;local cruiseSpeed=0.0
local function notify(t,k) exports.szcore_ui:Notify({description=t,type=k or 'inform'}) end
local function loadClip(name) RequestAnimSet(name);local timeout=GetGameTimer()+3000;while not HasAnimSetLoaded(name) and GetGameTimer()<timeout do Wait(20) end;return HasAnimSetLoaded(name) end
local function nearestVehicle(radius)
    local p=GetEntityCoords(PlayerPedId());local best=0;local bd=radius+0.01
    for _,v in ipairs(GetGamePool('CVehicle')) do local d=#(GetEntityCoords(v)-p);if d<bd then best=v;bd=d end end;return best,bd
end
if C.crouch then
    RegisterCommand('+szcorecrouch',function()
        local ped=PlayerPedId();if IsPedInAnyVehicle(ped,false) or IsPedRagdoll(ped) then return end
        crouched=not crouched
        if crouched and loadClip('move_ped_crouched') then SetPedMovementClipset(ped,'move_ped_crouched',0.25);SetPedStrafeClipset(ped,'move_ped_crouched_strafing') else ResetPedMovementClipset(ped,0.25);ResetPedStrafeClipset(ped) end
    end,false);RegisterCommand('-szcorecrouch',function() end,false);RegisterKeyMapping('+szcorecrouch','SzCore: Guggolás','keyboard','LCONTROL')
end
if C.cruise then
    RegisterCommand('szcorecruise',function()
        local ped=PlayerPedId();local veh=GetVehiclePedIsIn(ped,false);if veh==0 or GetPedInVehicleSeat(veh,-1)~=ped then return end
        if cruiseVeh==veh then SetEntityMaxSpeed(veh,1000.0);cruiseVeh=0;return notify('Tempomat kikapcsolva.') end
        cruiseVeh=veh;cruiseSpeed=GetEntitySpeed(veh);if cruiseSpeed<5.0 then cruiseVeh=0;return notify('Túl alacsony a sebesség.','error') end
        SetEntityMaxSpeed(veh,cruiseSpeed);notify(('Tempomat: %d km/h'):format(math.floor(cruiseSpeed*3.6+0.5)),'success')
    end,false);RegisterKeyMapping('szcorecruise','SzCore: Tempomat','keyboard','K')
    CreateThread(function() while true do if cruiseVeh~=0 then if not DoesEntityExist(cruiseVeh) or GetVehiclePedIsIn(PlayerPedId(),false)~=cruiseVeh or IsControlPressed(0,72) then if DoesEntityExist(cruiseVeh) then SetEntityMaxSpeed(cruiseVeh,1000.0) end;cruiseVeh=0 end;Wait(100) else Wait(700) end end end)
end
if C.noSeatShuffle then CreateThread(function() while true do SetPedConfigFlag(PlayerPedId(),184,true);Wait(1000) end end) end
if C.stunGroundTimeMs and C.stunGroundTimeMs>0 then CreateThread(function() while true do SetPedMinGroundTimeForStungun(PlayerPedId(),C.stunGroundTimeMs);Wait(1500) end end) end
if C.recoil and C.recoil.enabled then
    CreateThread(function() while true do local ped=PlayerPedId();if IsPedShooting(ped) then local w=GetSelectedPedWeapon(ped);local r=C.recoil.weapons[w] or C.recoil.default;if r and r>0 then local pitch=GetGameplayCamRelativePitch();SetGameplayCamRelativePitch(pitch+r*2.5,0.8);ShakeGameplayCam('SMALL_EXPLOSION_SHAKE',r) end;Wait(0) else Wait(60) end end end)
end
if C.tackle then
    RegisterCommand('+szcoretackle',function()
        local ped=PlayerPedId();if not IsPedSprinting(ped) then return end
        local p=GetEntityCoords(ped);local closest=-1;local dist=C.tackleDistance+0.01
        for _,player in ipairs(GetActivePlayers()) do if player~=PlayerId() then local tp=GetPlayerPed(player);local d=#(GetEntityCoords(tp)-p);if d<dist then closest=GetPlayerServerId(player);dist=d end end end
        if closest~=-1 then TriggerServerEvent('szcore_smallresources:tackle',closest);SetPedToRagdoll(ped,900,900,0,false,false,false) end
    end,false);RegisterCommand('-szcoretackle',function() end,false);RegisterKeyMapping('+szcoretackle','SzCore: Tackle','keyboard','G')
    RegisterNetEvent('szcore_smallresources:tackled',function() SetPedToRagdoll(PlayerPedId(),1800,1800,0,false,false,false) end)
end
if C.flipVehicle then
    RegisterCommand('flipvehicle',function() local v=nearestVehicle(3.5);if v==0 then return notify('Nincs jármű a közelben.','error') end;local r=GetEntityRotation(v,2);SetEntityRotation(v,0.0,r.y,r.z,2,true);SetVehicleOnGroundProperly(v);notify('Jármű talpra állítva.','success') end,false)
end
if C.vehiclePush then
    RegisterCommand('+szcorepush',function()
        local ped=PlayerPedId();if IsPedInAnyVehicle(ped,false) then return end;local v,d=nearestVehicle(3.0);if v==0 or d>3.0 then return end
        if GetVehicleNumberOfPassengers(v)>0 or not IsVehicleSeatFree(v,-1) then return end
        local endAt=GetGameTimer()+8000;RequestAnimDict('missfinale_c2ig_11');while not HasAnimDictLoaded('missfinale_c2ig_11') do Wait(10) end;TaskPlayAnim(ped,'missfinale_c2ig_11','pushcar_offcliff_m',2.0,2.0,-1,35,0,false,false,false)
        CreateThread(function() while GetGameTimer()<endAt and IsControlPressed(0,21) and DoesEntityExist(v) do local f=GetEntityForwardVector(ped);ApplyForceToEntity(v,1,f.x*0.7,f.y*0.7,0.03,0,0,0,0,false,true,true,false,true);Wait(0) end;ClearPedTasks(ped) end)
    end,false);RegisterCommand('-szcorepush',function() end,false);RegisterKeyMapping('+szcorepush','SzCore: Jármű tolása (SHIFT tartva)','keyboard','LSHIFT')
end
for _,tp in ipairs(C.teleports or {}) do
    if tp.from and tp.to then
        CreateThread(function()
            local showing=false
            while true do
                local p=GetEntityCoords(PlayerPedId());local d=#(p-tp.from)
                if d<20.0 then
                    if d<1.5 then
                        if not showing then exports.szcore_ui:ShowTextUI(('[E] %s'):format(tp.label or 'Átjutás'));showing=true end
                        if IsControlJustReleased(0,38) then local ped=PlayerPedId();SetEntityCoords(ped,tp.to.x,tp.to.y,tp.to.z,false,false,false,false);if tp.to.w then SetEntityHeading(ped,tp.to.w) end end
                    elseif showing then exports.szcore_ui:HideTextUI();showing=false end
                    Wait(0)
                else
                    if showing then exports.szcore_ui:HideTextUI();showing=false end
                    Wait(750)
                end
            end
        end)
    end
end
if C.infiniteUtilityAmmo then
    CreateThread(function()
        local ext=joaat('WEAPON_FIREEXTINGUISHER');local can=joaat('WEAPON_PETROLCAN')
        while true do local ped=PlayerPedId();SetPedInfiniteAmmo(ped,true,ext);SetPedInfiniteAmmo(ped,true,can);Wait(2000) end
    end)
end
if C.weaponDrawAnimation then
    CreateThread(function()
        local last=joaat('WEAPON_UNARMED')
        while true do
            local ped=PlayerPedId();local current=GetSelectedPedWeapon(ped)
            if current~=last and not IsPedInAnyVehicle(ped,false) and not IsPedRagdoll(ped) then
                local drawing=current~=joaat('WEAPON_UNARMED')
                local dict='reaction@intimidation@1h';RequestAnimDict(dict);local untilAt=GetGameTimer()+1000
                while not HasAnimDictLoaded(dict) and GetGameTimer()<untilAt do Wait(10) end
                if HasAnimDictLoaded(dict) then TaskPlayAnim(ped,dict,drawing and 'intro' or 'outro',3.0,3.0,650,48,0,false,false,false) end
            end
            last=current;Wait(180)
        end
    end)
end
RegisterNetEvent('szcore_smallresources:consumeEffect',function(kind)
    local ped=PlayerPedId()
    if kind=='beer' or kind=='vodka' or kind=='whiskey' then
        local strength=kind=='beer' and 0.12 or(kind=='vodka' and 0.28 or 0.22)
        ShakeGameplayCam('DRUNK_SHAKE',strength);SetTimecycleModifier('spectator5');SetTimecycleModifierStrength(math.min(0.65,strength+0.15))
        CreateThread(function() Wait(kind=='beer' and 20000 or 35000);StopGameplayCamShaking(true);ClearTimecycleModifier() end)
    elseif kind=='joint' then
        AnimpostfxPlay('DrugsMichaelAliensFight',25000,false);ShakeGameplayCam('DRUNK_SHAKE',0.08)
        CreateThread(function() Wait(25000);AnimpostfxStop('DrugsMichaelAliensFight');StopGameplayCamShaking(true) end)
    end
end)

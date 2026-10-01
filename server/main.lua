local lastTackle={}
RegisterNetEvent('szcore_smallresources:tackle',function(target)
    local src=source;target=tonumber(target);if not target or target==src then return end
    local now=GetGameTimer();if now-(lastTackle[src] or 0)<2500 then return end;lastTackle[src]=now
    local a,b=GetPlayerPed(src),GetPlayerPed(target);if a==0 or b==0 then return end
    if #(GetEntityCoords(a)-GetEntityCoords(b))>SzCoreSmallConfig.tackleDistance+0.7 then return end
    TriggerClientEvent('szcore_smallresources:tackled',target)
end)
AddEventHandler('playerDropped',function() lastTackle[source]=nil end)
local function inventoryId(src)local p=exports.szcore:GetPlayer(src);return p and ('player:'..p.PlayerData.citizenid) or nil end
local consumeEffects={beer={thirst=8,stress=-5},vodka={thirst=-4,stress=-8},whiskey={thirst=-2,stress=-7},joint={hunger=-2,thirst=-3,stress=-18}}
if SzCoreSmallConfig.consumables then
    for item,effect in pairs(consumeEffects) do
        exports.szcore_inventory:RegisterUsableItem(item,function(src,entry,slot)
            local id=inventoryId(src);if not id or not exports.szcore_inventory:RemoveItemBySlot(id,slot,1) then return false end
            for key,delta in pairs(effect) do
                local current=tonumber(exports.szcore:GetMetadata(src,key)) or 0
                exports.szcore:SetMetadata(src,key,math.max(0,math.min(100,current+delta)))
            end
            TriggerClientEvent('szcore_smallresources:consumeEffect',src,item)
            return true
        end)
    end
end

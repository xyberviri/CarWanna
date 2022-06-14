require 'Items/SuburbsDistributions'
require 'Items/ProceduralDistributions'

local SETTINGS               = CW.SETTINGS or {}
--[[    
local function has_value (tab, val)
  for index, value in ipairs(tab) do
      if value == val then
          return true
      end
  end
  return false
end
]]--
local function CarWanna_InsertTo_ProceduralDistributions(item, weight)
    print("CarWanna "..item..", item added to container loot. "..string.format("%f",weight))
    table.insert(ProceduralDistributions.list["PinkSlips"].items, item)
    table.insert(ProceduralDistributions.list["PinkSlips"].items, weight)
end

local function CarWanna_InsertTo_SuburbsDistributions(item, weight)
    print("CarWanna "..item..", item added to zed loot. "..string.format("%f",weight))
    table.insert(SuburbsDistributions["all"]["Outfit_Mechanic"].items, item)
    table.insert(SuburbsDistributions["all"]["Outfit_Mechanic"].items, weight)
end

local lootweights={1,5,10,20,50,100}
local pinkslipdamagesetting = { "None","Average","Random"  }
if (ModOptions and ModOptions.getInstance) or ( SETTINGS and SETTINGS.enabled) then	
    if ModOptions and not SETTINGS.enabled then
        print("CarWanna MOD OPTIONS DETECTED")							
        ModOptions:loadFile()
    else
        print("CarWanna LUA OPTIONS DETECTED")
    end
    print( "CarWanna Options" )
    print( "enablefoundloot = ", SETTINGS.options.enablefoundloot )
    print( "enablezedloot   = ", SETTINGS.options.enablezedloot )
    --print( "foundlootrarity  = ", SETTINGS.options.foundlootrarity )
    print( "foundlootweight = ", SETTINGS.options.foundlootweight )
    print( "zedlootrarity    = ", SETTINGS.options.zedlootrarity )
    --print( "pinkslipdamage  = ", SETTINGS.options.pinkslipdamage)
    print( "user blacklist  = ", SETTINGS.options.blacklist )
    print( "mod blacklist   = ", table.concat(SETTINGS.mod_blacklist, ", "))
    
    if ( SETTINGS.options.enablefoundloot or SETTINGS.options.enablezedloot ) then
        --SETTINGS.options.LootChance     = ( 10^SETTINGS.options.foundlootrarity / 100000 ) --1000000000 )
        SETTINGS.options.LootWeight     = ( lootweights[SETTINGS.options.foundlootweight] or 1 )
        SETTINGS.options.ZedLootChance  = ( 10^SETTINGS.options.zedlootrarity   / 100000 ) --1000000000 )
        if getDebug() then
            --print( "CarWanna calculated Found Loot Base Weight  : "..SETTINGS.options.LootChance )   --string.format("%f",SETTINGS.options.LootChance))
            print( "CarWanna Found Loot Weight : ".. SETTINGS.options.LootWeight )
            print( "CarWanna ZombieLoot Chance   : "..SETTINGS.options.ZedLootChance )  --string.format("%f",SETTINGS.options.ZedLootChance))
      --      print( "CarWanna Found and Zed PinkSlip Loot Damage : "..pinkslipdamagesetting[SETTINGS.options.pinkslipdamage])
        end
        --Make sure mechanic outfit exists in loot table. 
        if SETTINGS.options.enablezedloot then
            SuburbsDistributions.all.Outfit_Mechanic = SuburbsDistributions.all.Outfit_Mechanic or {rolls = 1,items = {},junk= {rolls =1, items={}}}
        end
        --Add Pinkslip loot distribution list
        if SETTINGS.options.enablefoundloot then
            ProceduralDistributions.list.PinkSlips = ProceduralDistributions.list.PinkSlips or {rolls = 1,items = {},junk = {rolls = 1, items={}}}
                local PinkSlipContainer = {name="PinkSlips", min=0, max=1, weightChance=SETTINGS.options.LootWeight}                
                    table.insert(SuburbsDistributions.mechanic.crate.procList, PinkSlipContainer)
                    table.insert(SuburbsDistributions.mechanic.metal_shelves.procList, PinkSlipContainer)                
                    table.insert(SuburbsDistributions.pawnshop.counter.procList, PinkSlipContainer)
                    table.insert(SuburbsDistributions.pawnshop.displaycase.procList, PinkSlipContainer)
                    table.insert(SuburbsDistributions.policestorage.crate.procList, PinkSlipContainer)
                    table.insert(SuburbsDistributions.policestorage.counter.procList, PinkSlipContainer)

                --table.insert(SuburbsDistributions.mechanic.wardrobe.procList, PinkSlipContainer)
                --table.insert(SuburbsDistributions.pawnshopoffice.crate.procList, PinkSlipContainer)                
                --table.insert(SuburbsDistributions.pawnshopoffice.metal_shelves.procList, PinkSlipContainer)
                
        end
        
        --Build blacklist
        local blacklist = {}
        --[[
        --old
        if string.len(SETTINGS.options.blacklist) > 1 then
            blacklist = string.split(SETTINGS.options.blacklist, ";");
        end        
        for _,v in ipairs(SETTINGS.mod_blacklist) do 
            table.insert(blacklist, v)
        end
        ]]--


        --User Config Settings
        if string.len(SETTINGS.options.blacklist) > 1 then
            --SETTINGS.options.blacklist:gsub("\"", "")
            local temp = string.split(SETTINGS.options.blacklist, ";");     
            for _,v in ipairs(temp) do 
              blacklist[v]=true
            end
        end
        --Lua Config Settings
        for _,v in ipairs(SETTINGS.mod_blacklist) do 
            blacklist[v]=true            
        end







        local items = getAllItems()
        for i=0,items:size()-1 do
            local item = items:get(i);        
            if (item:getModuleName() == "PinkSlip") then
                local itemname = item:getFullName()
                if blacklist[itemname] then
                --if has_value(blacklist,itemname) then
                    print("CarWanna "..itemname..", item is blacklisted by config.")
                else
                    local scriptItem = instanceItem(itemname)
                    local modData = scriptItem:getModData()
                    local vehicle = ScriptManager.instance:getVehicle(modData.VehicleID)
                    if vehicle then
                    --Spawned Vehicle Exists
                        if not modData.isBlacklisted then
                        --Not on any blacklist
                            if SETTINGS.options.enablefoundloot then
                                CarWanna_InsertTo_ProceduralDistributions(itemname, modData.LootChance or 1) -- 100 - 0.0001
                            end
                            if SETTINGS.options.enablezedloot then
                                CarWanna_InsertTo_SuburbsDistributions(itemname, SETTINGS.options.ZedLootChance)
                            end
                        else
                            print("CarWanna "..itemname..", item is blacklisted by pinkslip.")
                        end
                    else
                        print("CarWanna "..itemname..", item Not Added, the vehicle it spawns, "..modData.VehicleID..", was not found.")
                    end                    
                end
                --[[
                if SandboxVars.CarWanna.EnablePinkSlipDamaged then
                print("Setting Condition")
                    local scriptItem = ScriptManager.instance:getItem(itemname)
                    if scriptItem then
                        scriptItem:DoParam("ConditionMax	=	100")
                        scriptItem:DoParam("ConditionLowerChanceOneIn = 10")
                    end 
                end
                ]]--
            end
        end
    else
        print("CarWanna All Loot Drops Options Disable.")
    end
end
require 'Items/SuburbsDistributions'
require 'Items/ProceduralDistributions'
require "Items/ItemPicker"

CWTitleVehicle = CWTitleVehicle or {}
CWTitleVehicle.PartWhitelist = CWTitleVehicle.PartWhitelist or {}
CWTitleVehicle.VehicleBlacklist = CWTitleVehicle.VehicleBlacklist or {}

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
    print("CarWanna "..item..", item added to container loot, weight is "..string.format("%f",weight))
    table.insert(ProceduralDistributions.list["PinkSlips"].items, item)
    table.insert(ProceduralDistributions.list["PinkSlips"].items, weight)
end

local function CarWanna_InsertTo_SuburbsDistributions(item, weight)
    print("CarWanna "..item..", item added to zed loot, weight is "..string.format("%f",weight))
    table.insert(SuburbsDistributions["all"]["Outfit_Mechanic"].items, item)
    table.insert(SuburbsDistributions["all"]["Outfit_Mechanic"].items, weight)
end

--local lootweights={1,5,10,20,50,100}
--local pinkslipdamagesetting = { "None","Average","Random"  }
local OnInitGlobalModData = function(newGame)
    print( "CarWanna Options" )
    print( "enablefoundloot = ", SandboxVars.CarWanna.EnableFoundLoot )
    print( "enablezedloot   = ", SandboxVars.CarWanna.EnableZedLoot )
    --print( "foundlootrarity  = ", SETTINGS.options.foundlootrarity )
    print( "foundlootweight = ", SandboxVars.CarWanna.FoundLootChance )
    print( "zedlootrarity    = ", string.format("%f",SandboxVars.CarWanna.ZedLootChance) )
    --print( "pinkslipdamage  = ", SETTINGS.options.pinkslipdamage)
    print( "pinkslip blacklist setting  = ", SandboxVars.CarWanna.LootBlackList )
    --print( "mod blacklist   = ", table.concat(SETTINGS.mod_blacklist, ", "))
    

    --Build Part Whitelist
    if string.len(SandboxVars.CarWanna.PartWhiteList) > 0 then
        local temp = string.split(SandboxVars.CarWanna.PartWhiteList, ";");     
        for _,v in ipairs(temp) do 
          CWTitleVehicle.PartWhitelist[v]=true
        end
    end
    
     --Build Vechile Blacklist
    if string.len(SandboxVars.CarWanna.VehicleBlacklist) > 0 then
        local temp = string.split(SandboxVars.CarWanna.VehicleBlacklist, ";");     
        for _,v in ipairs(temp) do 
          CWTitleVehicle.VehicleBlacklist[v]=true
        end
    end
    
    if SandboxVars.CarWanna.NeedForm and SandboxVars.CarWanna.FormLoot then
        local formitem = "Base.AutoForm"
        local formchance = SandboxVars.CarWanna.FormChance or 1
        print("Adding Base.AutoForm to loot tables at "..formchance)
        table.insert(ProceduralDistributions.list["OfficeDesk"].items, formitem )
        table.insert(ProceduralDistributions.list["OfficeDesk"].items, formchance )
        table.insert(ProceduralDistributions.list["PoliceDesk"].items, formitem )
        table.insert(ProceduralDistributions.list["PoliceDesk"].items, formchance )
    end
    
    
    
    if ( SandboxVars.CarWanna.EnableFoundLoot or SandboxVars.CarWanna.EnableZedLoot  ) then
        --Make sure mechanic outfit exists in loot table. 
        if SandboxVars.CarWanna.EnableZedLoot then
            SuburbsDistributions.all.Outfit_Mechanic = SuburbsDistributions.all.Outfit_Mechanic or {rolls = 1,items = {},junk= {rolls =1, items={}}}
        end
        --Add Pinkslip loot distribution list
        if SandboxVars.CarWanna.EnableFoundLoot then
            ProceduralDistributions.list.PinkSlips = ProceduralDistributions.list.PinkSlips or {rolls = 1,items = {},junk = {rolls = 1, items={}}}
                local PinkSlipContainer = {name="PinkSlips", min=0, max=1, weightChance=SandboxVars.CarWanna.FoundLootChance} --Setting this to min=1, max=1 makes these spawn almost too much.
                    table.insert(SuburbsDistributions.mechanic.crate.procList, PinkSlipContainer)
                    table.insert(SuburbsDistributions.mechanic.metal_shelves.procList, PinkSlipContainer)  
                    
                    table.insert(SuburbsDistributions.pawnshop.counter.procList, PinkSlipContainer)
                    table.insert(SuburbsDistributions.pawnshop.displaycase.procList, PinkSlipContainer)
                    
                    table.insert(SuburbsDistributions.policestorage.crate.procList, PinkSlipContainer)
                    table.insert(SuburbsDistributions.policestorage.counter.procList, PinkSlipContainer)
                    table.insert(SuburbsDistributions.policestorage.locker.procList, PinkSlipContainer)
                    table.insert(SuburbsDistributions.policestorage.metal_shelves.procList, PinkSlipContainer)

                --table.insert(SuburbsDistributions.mechanic.wardrobe.procList, PinkSlipContainer)
                --table.insert(SuburbsDistributions.pawnshopoffice.crate.procList, PinkSlipContainer)                
                --table.insert(SuburbsDistributions.pawnshopoffice.metal_shelves.procList, PinkSlipContainer)
                
        end
        
        --Build blacklist
        local blacklist = {}
        if string.len(SandboxVars.CarWanna.LootBlackList) > 0 then
            --SETTINGS.options.blacklist:gsub("\"", "")
            local temp = string.split(SandboxVars.CarWanna.LootBlackList, ";");     
            for _,v in ipairs(temp) do 
              blacklist[v]=true
            end
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
                            if SandboxVars.CarWanna.EnableFoundLoot then
                                CarWanna_InsertTo_ProceduralDistributions(itemname, modData.LootChance or 1) -- 100 - 0.0001
                            end
                            if SandboxVars.CarWanna.EnableZedLoot then
                                CarWanna_InsertTo_SuburbsDistributions(itemname, SandboxVars.CarWanna.ZedLootChance)
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
        print("CarWanna pinkslip loot options are disable.")
    end
    
    
    if (SandboxVars.CarWanna.NeedForm and SandboxVars.CarWanna.FormLoot) or SandboxVars.CarWanna.EnableZedLoot or SandboxVars.CarWanna.EnableFoundLoot then
        CWTitleVehicle.ReloadDistributionSettings()        
    end
end

CWTitleVehicle.ReloadDistributionSettings = function()
    print("CarWanna added loot, reloading loot tables")
        ItemPickerJava.Parse()
end

--[[
local OnInitGlobalModData = function(newGame)
if newGame then 
    print("CARWANNA NEW GAME DETECTED")
end
print("CARWANNA Minimum Chance ",string.format("%f",SandboxVars.CarWanna.ZedLootChance))
print("CARWANNA Need Form ",tostring(SandboxVars.CarWanna.NeedForm))
print("CARWANNA Must have all parts ",tostring(SandboxVars.CarWanna.MustHaveAllParts))
print("CARWANNA Minmum Condition ",tostring(SandboxVars.CarWanna.MinmumCondition))
end
]]--

--Yeah we probably shouldn't do this, this loads a lot more than the sandbox options and this causes this event to fire off twice.
local EarlyBootSandbox = function(newGame)
    if not SandboxVars and not isClient() then
        print("CarWanna Attempting to load sandbox options earlier than normal")
            getSandboxOptions().load()
    end
end
--Events.OnPreDistributionMerge.Add(EarlyBootSandbox)
--Events.OnPostDistributionMerge.Add(OnInitGlobalModData)

Events.OnInitGlobalModData.Add(OnInitGlobalModData)


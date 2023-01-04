--[[
    CarWanna, Multiplayer car spawning library for Project Zomboid. 
    Copyright (C) 2022  Xyberviri

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    TLDR Version:
    https://tldrlegal.com/license/gnu-general-public-license-v3-(gpl-3)
    
                               //*,..       ..,*//                              
                      .*.                               .*.                     
   (@@@@@@@@@@@@@@#*       ,(%@@@@@@@@@@@@@@@@@@@@@%(,       *#@@@@@@@@@@@@@@#  
   (@@@@@@@@@@@/.     *%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%*.    ./@@@@@@@@@@@#  
   (@@@@@@@@/.    *&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*     /@@@@@@@@#  
   (@@@@@%,    *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*    ,#@@@@@#  
   (@@@%,    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%.   .%@@@#  
   (@&,   .%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%.   ,&@#  
   (/    #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#    /#  
   *   ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,   *  
  *   *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*   * 
 .   *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/   .
 .  .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.  .
*   %@@@@@#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&(%@@@@@@&   
.  ,@@@@%.    /&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&/     *@@@@@@,  
   /@@@&.        ,&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*         (@@@@@(  
   (@@@#        .&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*        /@@@@@#  
   /@@@&,       .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/        #@@@@@(  
.  ,@@@@&.       .&@@@@@@@@@* /&@@@@@@@@@@@@@@@@/ .&@@@@@@@@@/        #@@@@@@,  
*   %@@@@@(         ./(((,       .@@@@@@@@@@@,       ,((#(*         /@@@@@@@&   
 .  .@@@@@@@&*                 /&@@@@@@@@@@@@@@#,                *%@@@@@@@@@.  .
 .   *@@@@@@@@@@&%(/*,,,**#%@@@@@@@@@@@@@@@@@@@@@@@&%#/****/#%@@@@@@@@@@@@@/   .
  *   *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*   * 
   *   ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,   *  
   (/    #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#    /#  
   (@&,   .%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%.   ,&@#  
   (@@@%,    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%.   .%@@@#  
   (@@@@@%,    *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*    ,#@@@@@#  
   (@@@@@@@@/.    *&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*     /@@@@@@@@#  
   (@@@@@@@@@@@/.     *%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%*.    ./@@@@@@@@@@@#  
   (@@@@@@@@@@@@@@#*       ,(%@@@@@@@@@@@@@@@@@@@@@%(,       *#@@@@@@@@@@@@@@#  
                      .*.                               .*.                     

    Tips Accepted by not required Happy Modding..... 
    
    https://ko-fi.com/xyberviri
    https://www.paypal.me/xyberviri


--]]
if isClient() then return end
CW_fueltankPartNames = {"1000FuelTank","500FuelTank"}
local CWCommands = {}
local Commands = {}

CWCommands.wantNoise = getDebug() or false

local noise = function(msg)
	if CWCommands.wantNoise then
		print('[CarWanna]: '..msg)
	end
end
--[[
  public void setEngineFeature(int var1, int var2, int var3) {
      this.engineQuality = PZMath.clamp(var1, 0, 100);
      this.engineLoudness = (int)((float)var2 / 2.7F);
      this.enginePower = var3;
      
         byte var6 = 100;
         int var7 = (int)((double)var1.getEngineLoudness() * SandboxOptions.getInstance().ZombieAttractionMultiplier.getValue());
         int var5 = (int)var1.getEngineForce();
         this.vehicle.setEngineFeature(var6, var7, var5);
         this.vehicle.transmitEngine();
   }
   ]]--
local function setEngineQuality(vehicle, engineQuality)
	engineQuality = math.max(engineQuality, 0)
	engineQuality = math.min(engineQuality, 100)
    
	local engineLoudness = vehicle:getScript():getEngineLoudness() or 100
	engineLoudness = engineLoudness * (SandboxVars.ZombieAttractionMultiplier or 1)
   
    local enginePower = vehicle:getScript():getEngineForce()
	vehicle:setEngineFeature(engineQuality, engineLoudness, enginePower)
    vehicle:transmitEngine()
end

function Commands.spawnVehicle(player, args)
    print('[CarWanna]: Spawning Vehicle : '..args.type..' at '..player:getX()..' x '..player:getY()..' for '..player:getUsername())    
    local sq = getCell():getGridSquare(player:getX(), player:getY(), 0)
    
    if args.dir == nil then
        if player then
            args.dir = player:getDir();
        else
            args.dir = IsoDirections.S;
        end
    end
    
    if args.skin == nil then  
        args.skin = -1
    end    
    
    
    local experimental = nil
    local experimental_target = nil
    if args.color and SandboxVars.CarWanna.ExperimentalColor then
        local mod
        experimental = ScriptManager.instance:getVehicle(args.type)	
        mod, experimental_target = args.type:match"([^.]*).(.*)"
        experimental:Load(experimental_target, "{ forcedColor ="..args.color.h.." "..args.color.s.." "..args.color.v..",".."}") 
    end

    local car = addVehicleDebug(args.type, args.dir, args.skin, sq)
    print("[CarWanna]: Vehicle Created ID: "..car:getId())
    car = getVehicleById(car:getId())
    
    if args.color and not SandboxVars.CarWanna.ExperimentalColor then
        noise("Coloring Vehicle ",args.color.h, args.color.s, args.color.v)
        car:setColorHSV(args.color.h, args.color.s, args.color.v)
        car:transmitColorHSV()
    end
    
    if experimental and experimental_target then
        experimental:Load(experimental_target, "{ forcedColor =".."-1 -1 -1"..",".."}")     
    end
    
    if args.enginequality then
        setEngineQuality(car,args.enginequality)
    end
    --car:setDir(args.dir)
    
    --This repairs all parts on vehicles and also adds all upgrades since "missing" upgrades are parts with 0 health...    
    if args.upgrade then
        car:repair()
    end
    --
    --Main part loop
    --
    for i = 0, car:getPartCount() -1 
    do
        local part = car:getPartByIndex(i)
        --local partItem = part:getInventoryItem()
        local partId = part:getId()
        --print(partId)
        if part:getCategory() ~= "nodisplay" then
        --
        -- Visible parts that a player can repair.
        --            
            if part:getItemType() and not part:getItemType():isEmpty() then
            --This is a "real" part
                if args.parts then
                    --
                    -- New Base.AutoTitle pinkslips, these items are player created.
                    --
                    local partdata = args.parts[partId]
                    if partdata then
                        if part:getInventoryItem() and part:getInventoryItem():getFullType() == partdata["Item"] then
                           noise(partdata["Item"].." already installed.")
                        else

                            if part:getInventoryItem() then
                                noise("swapping "..part:getInventoryItem():getFullType().." for "..partdata["Item"])
                                part:setInventoryItem(nil)
                                car:transmitPartItem(part)
                            else
                                --part:setInventoryItem(nil)
                                --car:transmitPartItem(part)
                                noise("Installing "..partdata["Item"])
                            end
             
                            
                            local item = InventoryItemFactory.CreateItem(partdata["Item"]) 
                            part:setInventoryItem(item)                            
                            local tbl = part:getTable("install")
                            if tbl and tbl.complete then
                                VehicleUtils.callLua(tbl.complete, car, part)
                            end                            
                            car:transmitPartItem(part)
                        end

                        --At this point we should have a InventoryItem on part and can safely do stuff.
                        part:setCondition(partdata["Condition"])                        
                        car:transmitPartCondition(part)
                        
                        --fix this bullshit.
                        if part:getDoor() and part:getDoor():isLockBroken() then
                            noise("Fixing door at "..partId)
                            part:getDoor():setLockBroken(false)
                            car:transmitPartDoor(part)
                        end
                        
                        --Parts that hold things, typically spawn with stuff, we'll need to clear those things. 
                        local container = part:getItemContainer()
                        if container and container:getItems():size() ~= 0 and args.clear then
                            container:removeAllItems()
                        end
                        
                        --Parts are like the avatar they can hold things like gas, air, fire, earth and water
                        local content = partdata["Content"]
                        if content then
                            part:setContainerContentAmount(content)
                            local wheelIndex = part:getWheelIndex()
                            if wheelIndex ~= -1 then
                                noise("Setting tire pressure at index "..wheelIndex)
                                car:setTireInflation(wheelIndex, part:getContainerContentAmount() / part:getContainerCapacity())
                            end
                        end
                        --So far the only thing i found using Delta is batteries, so its kinda sort of but not really safe to say these are for batteries. 
                        local delta = partdata["Delta"]
                        if delta then
                            part:getInventoryItem():setUsedDelta(delta)
                            car:transmitPartUsedDelta(part)
                        end               
                        --This wasn't required to work previously but vanilla does this so let's do that just in case. 
                        car:transmitPartModData(part)
                    else
                        noise("removing "..partId..", part does not exist on pinkslip.")
                        part:setInventoryItem(nil)
                        --Make advanced vehicles like KI5 work
                        local tbl = part:getTable("uninstall")
                        if tbl and tbl.complete then
                            VehicleUtils.callLua(tbl.complete, car, part)
                        end
                        car:transmitPartItem(part)
                    end
                    --
                    -- end of player pinkslip
                    --
                else
                    --
                    -- Precreated pinkslips end up in here. 
                    --
                    local item = part:getInventoryItem()                    
                    if item then
                    --
                    -- This part is "installed" on our vehicle.
                    --
                    
                       local container = part:getItemContainer()
                        if container and container:getItems():size() ~= 0 and args.clear then
                            container:removeAllItems()
                        end
                    
                        if args.condition then
                            part:setCondition(args.condition)
                            item:setCondition(args.condition)
                            car:transmitPartCondition(part)
                        end
                        
                        
                        if part:getDoor() and part:getDoor():isLockBroken() then
                            noise("Fixing door at "..partId)
                            part:getDoor():setLockBroken(false)
                            car:transmitPartDoor(part)
                        end
                        
                        --This should set the charge on all "battery" items like the 3 on the KI5 Generator
                        if item:IsDrainable() and args.battery and string.find(partId, "Battery") then
                            item:setUsedDelta(args.battery)
                        end
                
                        --This part holds fluids of some type and isn't a real container
                        if part:isContainer() and not container then
                            local wheelIndex = part:getWheelIndex()
                            if partId == "GasTank" then
                                if args.gastank then
                                    part:setContainerContentAmount(math.min(args.gastank,part:getContainerCapacity()))
                                end
                            elseif wheelIndex ~= -1 then --string.find(partId, "Tire") then
                                if  args.tirepsi then
                                    part:setContainerContentAmount(math.min(args.tirepsi,part:getContainerCapacity()))
                                    car:setTireInflation(wheelIndex, part:getContainerContentAmount() / part:getContainerCapacity())
                                end
                            elseif args.othertank then
                                part:setContainerContentAmount(math.min(args.othertank,part:getContainerCapacity()))
                            end                            
                        end
                        
                        car:transmitPartModData(part)
                    --
                    -- End of "installed" parts
                    --
                    end
                    --
                    -- End of Precreated pinkslips
                    --
                end
            --End of real parts with real items. 
            else
            --This is a part that can not be removed, we should have a condition for it if not its probably something we cant repair. 
                if args.condition then
                    part:setCondition(args.condition)
                    car:transmitPartCondition(part)
                elseif args.parts and args.parts[partId] then
                    local newcondition = args.parts[partId]["Condition"] or nil
                    if newcondition then   
                        part:setCondition(newcondition)
                        car:transmitPartCondition(part)
                    end
                end                        
            --
            --End of parts we can not remove.
            --
            end        
        --
        -- End of visible parts
        --
        else
        --
        -- These parts are hidden from the mechanic overlay.
        --
            if SandboxVars.CarWanna.FixNodisplay then
                part:setCondition(100)
            end
            noise("Skipping "..partId..", since its set to nodisplay ")
        end
        --
        -- End noise for nodisplay items.
        --
    end
    --  
    --End main part loop
    --
   


    if args.rust then
        car:setRust(args.rust)
        car:transmitRust()
    end
    
    if args.blood then
        if args.blood.f > 0 then
            car:setBloodIntensity("Front",args.blood.f)
        end
        if args.blood.b > 0 then
            car:setBloodIntensity("Rear",args.blood.b)
        end
        if args.blood.l > 0 then
            car:setBloodIntensity("Left",args.blood.l)
        end
        if args.blood.r > 0 then
            car:setBloodIntensity("Right",args.blood.r)
        end
    end
    
    if args.hotwire then
        car:setHotwired(true)
    elseif car:isHotwired() then
            car:setHotwired(false)        
    end
    --Create a key and send it to the player..
    if args.makekey then 
        local newCarKey = car:createVehicleKey()
        if newCarKey then
        
            if player then
                player:sendObjectChange("addItem", { item = newCarKey })
            else
                sq:AddWorldInventoryItem(newCarKey, ZombRand(1, 5), ZombRand(1, 5), 0)
            end
            
        end
    end
--Done
end

function Commands.spawnVehicleLegacy(player, args)
    print("[CarWanna]: spawnVehicleLegacy called, WARNING THIS METHOD IS OBSOLETE AND WILL BE REMOVED IN A FUTURE UPDATE!!!")
    print('[CarWanna]: Spawning Vehicle : '..args.type..' at '..player:getX()..' x '..player:getY()..' for '..player:getUsername())    
    local sq = getCell():getGridSquare(player:getX(), player:getY(), 0)
    
    if args.dir == nil then
        if player then
            args.dir = player:getDir();
        else
            args.dir = IsoDirections.S;
        end
    end
    
    if args.skin == nil then  
        args.skin = -1
    end    
    
    local car = addVehicleDebug(args.type, args.dir, args.skin, sq)
    if args.enginequality then
        setEngineQuality(car,args.enginequality)
    end
    --car:setDir(args.dir)
    
    --This repairs all parts on vehicles and also adds all upgrades since "missing" upgrades are parts with 0 health...    
    if args.upgrade then
        car:repair()
    end
    
    --Clear out part inventories of random items that spawn in when we spawn vehicles in. 
    if args.clear then    
        for i = 0, car:getPartCount() -1 
        do
            local part = car:getPartByIndex(i)
            --print(part:getId())
            local container = part:getItemContainer()
            if container then
                --print("Is container")
                if container:getItems():size() ~= 0 then
                    --print("Has items")
                    container:removeAllItems()
                end
            end
        end
    end
    
    --Repair parts that actually exist on the vehicle
    --NOTE: this may or may not actually work properly see above method for proper method. 
    if (type(args.condition) == "number") then
        for i = 0, car:getPartCount() -1 
        do
            local part = car:getPartByIndex(i)
            if part:getCondition() > 0 then
                part:setCondition(args.condition)
            end
        end
    end
    
    --Set battery charge
    if args.battery then
        local battery = car:getPartById("Battery")
        if battery then
            battery:getInventoryItem():setUsedDelta(args.battery);
        end
    end
    
    --Create a key and send it to the player..
    if args.makekey then 
        local newCarKey = car:createVehicleKey()
        if newCarKey then
            player:sendObjectChange("addItem", { item = newCarKey })
            --sq:AddWorldInventoryItem(newCarKey, ZombRand(1, 5), ZombRand(1, 5), 0)
        end
        
    end
    
    --Change "GasTank" fill level if value exist. 
    --IF this isnt set vehicle spawns in with random amount of gas
    if args.gastank then
        local gastank = car:getPartById("GasTank")     
        if gastank then 
            gastank:setContainerContentAmount(args.gastank)
        end
    end    
    
    --Change fuel storage container amount, this is normally used by trailers.
    if args.fueltank then
        for i=1, #CW_fueltankPartNames
        do          
          local fueltank = car:getPartById(CW_fueltankPartNames[i])
          if fueltank then 
             fueltank:setContainerContentAmount(args.fueltank)
          end
        end 
    end    
    
end

CWCommands.OnClientCommand = function(module, command, player, args)
	if module == 'CW' and Commands[command] then
		local argStr = ''
		args = args or {}
		for k,v in pairs(args) do
			argStr = argStr..' '..k..'='..tostring(v)
		end
		noise('received '..module..' '..command..' '..tostring(player)..argStr)
		Commands[command](player, args)
	end
end

Events.OnClientCommand.Add(CWCommands.OnClientCommand)
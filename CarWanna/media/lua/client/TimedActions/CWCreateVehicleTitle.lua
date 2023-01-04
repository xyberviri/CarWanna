require "TimedActions/ISBaseTimedAction"

CWCreateVehicleTitle = ISBaseTimedAction:derive("CWCreateVehicleTitle")

function CWCreateVehicleTitle:isValid()
    return self.vehicle and not self.vehicle:isRemovedFromWorld()
end

function CWCreateVehicleTitle:waitToStart()
    self.character:faceThisObject(self.vehicle)
    return self.character:shouldBeTurning()
end

function CWCreateVehicleTitle:update()
    self.character:faceThisObject(self.vehicle)
    self.character:setMetabolicTarget(Metabolics.LightDomestic)
    if not self.character:getEmitter():isPlaying(self.sound) then
        self.sound = self.character:playSound("CreatePinkSlip")
    end
end

function CWCreateVehicleTitle:start()
    self:setActionAnim("VehicleWorkOnMid")
    self.sound = self.character:playSound("CreatePinkSlip")
end

function CWCreateVehicleTitle:stop()
    if self.sound ~= 0 then
        self.character:getEmitter():stopSound(self.sound)
    end
    ISBaseTimedAction.stop(self)
end

function CWCreateVehicleTitle:perform()
    if self.sound ~= 0 then
        self.character:getEmitter():stopSound(self.sound)
    end

    local vehicleName = getText("IGUI_VehicleName"..self.vehicle:getScript():getName())    
    local pinkSlip = self.character:getInventory():AddItem("Base.AutoTitle");
    pinkSlip:setName("PinkSlip: "..vehicleName.." (used)")  
      
    local pinkSlipModData = pinkSlip:getModData()
    pinkSlipModData["VehicleID"] = self.vehicle:getScript():getFullName()
    pinkSlipModData["VehicleName"] = vehicleName
    pinkSlipModData["Skin"] = self.vehicle:getSkinIndex()
    pinkSlipModData["Rust"] = self.vehicle:getRust()
    pinkSlipModData["BloodF"] = self.vehicle:getBloodIntensity("Front")
    pinkSlipModData["BloodB"] = self.vehicle:getBloodIntensity("Rear")
    pinkSlipModData["BloodL"] = self.vehicle:getBloodIntensity("Left")
    pinkSlipModData["BloodR"] = self.vehicle:getBloodIntensity("Right")
    
    pinkSlipModData["ColorH"] = self.vehicle:getColorHue()
    pinkSlipModData["ColorS"] = self.vehicle:getColorSaturation()
    pinkSlipModData["ColorV"] = self.vehicle:getColorValue()

    local key = self.character:getInventory():haveThisKeyId(self.vehicle:getKeyId())
    if key then 
        pinkSlipModData["HasKey"] = true
        key:getContainer():Remove(key)
    end
    pinkSlipModData["HotWired"] = self.vehicle:isHotwired()
    pinkSlipModData["EngineQuality"] = self.vehicle:getEngineQuality()

    pinkSlipModData["Parts"] = pinkSlipModData["Parts"] or {}
    local pinkSlipPartData = pinkSlipModData["Parts"]
    
    local missingParts = 0
    local brokenParts = 0
    
    for i = 1, self.vehicle:getPartCount() do
        local part = self.vehicle:getPartByIndex(i - 1)
        local partItem = part:getInventoryItem()
        local partId = part:getId()
        local partCondition = part:getCondition()
        
        --"Real" Part, not installed
--[[        
            if partItem then            
                print("Part ID: "..partId)
                print("Item Type: "..partItem:getFullType())
                print("Item Name: "..partItem:getName())                              
                if partItem:IsDrainable()  then
                    print("Drainable: "..partItem:getUsedDelta()) -- This is a battery --tostring(canDrain)
                end
                
                --print("IsContainer: "..tostring(part:isContainer()))                
                --print("MaxCapacity: "..partItem:getMaxCapacity())
                local container = part:getItemContainer()
                if container then
                    print("Container: "..container:getItems():size())  --This holds items
                end
                if not container and part:isContainer() then
                    print("Content: "..part:getContainerContentAmount()) --this holds fluids
                end
            else
                print("Part ID: "..partId)
                if part:getItemType() and not part:getItemType():isEmpty() then
                    print("Item Type: MISSING")
                    print("Item Name: MISSING")
                else
                    print("Item Type: nopart")
                    print("Item Name: nopart")
                end                
            end
]]--    
        
        --Visible Parts we can repair
        if part:getCategory() ~= "nodisplay" then
            --Vehicle parts with inventory items we can remove
            if part:getItemType() and not part:getItemType():isEmpty() then
                if partItem then
                    pinkSlipPartData[partId] = {}
                    pinkSlipPartData[partId]["Condition"] = partItem:getCondition() --math.min(partItem:getCondition(),partCondition) Check against part maybe?
                    pinkSlipPartData[partId]["Item"] = partItem:getFullType()
                    
                    --This part holds fluids
                    if part:isContainer() and not part:getItemContainer() then
                        pinkSlipPartData[partId]["Content"] = part:getContainerContentAmount()
                    end
                    --This is a battery
                    if partItem:IsDrainable() then
                        pinkSlipPartData[partId]["Delta"] = partItem:getUsedDelta()
                    end
                    --Count Broken parts
                    if partCondition < 100 or partItem:getCondition() < 100 then
                        brokenParts = brokenParts + 1
                    end
                    --End of installed parts
                else
                    --Part not installed, mark it on the pinkSlip
                    missingParts = missingParts + 1
                end
            --Vehicle parts with out items.
            else 
                --These are items that have no parts
                pinkSlipPartData[partId] = {}
                pinkSlipPartData[partId]["Condition"] = partCondition                
                if partCondition < 100 then
                    brokenParts = brokenParts + 1
                end
            end            
        end
        --end of Visible Parts we can repair

    -- End of loop though vehicle parts.
    end

    pinkSlipModData["Missing"] = missingParts
    pinkSlipModData["Broken"] = brokenParts
    --Get rid of the form if required.
    if SandboxVars.CarWanna.NeedForm then
        local form = self.character:getInventory():getFirstTypeRecurse("AutoForm")
        form:getContainer():Remove(form)
    end


    --Give the player the pinkSlip        
    self.character:getInventory():AddItem(pinkSlip)
    -- Remove the vehicle
    sendClientCommand(self.character, "vehicle", "remove", { vehicle = self.vehicle:getId() })
    
    if UdderlyVehicleRespawn and SandboxVars.CarWanna.UdderlyRespawn then
        UdderlyVehicleRespawn.SpawnRandomVehicleAtRandomZoneInRandomCell()
    end
    --Done
    ISBaseTimedAction.perform(self)
end

function CWCreateVehicleTitle:IsPartMissing(part)
    return part:getItemType() and not part:getItemType():isEmpty() and not part:getInventoryItem()
end

function CWCreateVehicleTitle:new(character, vehicle)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.stopOnWalk = true
    o.stopOnRun = true
    o.character = character
    o.vehicle = vehicle
    o.maxTime = 600
    
    if character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end
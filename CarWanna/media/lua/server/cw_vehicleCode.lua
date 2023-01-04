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
function Recipe.GetItemTypes.PinkSlip(scriptItems)
    scriptItems:addAll(getScriptManager():getItemsTag("PinkSlip"))
end 
    
function Recipe.OnCanPerform.CW_ClaimVehicle(recipe, playerObj, item)
    if playerObj:isOutside() and playerObj:getZ() == 0 then
        return true
    end    
    return false
end

function Recipe.OnCreate.CW_ClaimVehicle(items, result, player)
    local pinkslip = items:get(0)

    if not player:isOutside() or player:getZ() > 0 then
    --This shouldn't happen, but if it some how does give them back the pinkslip.
        player:Say("This wont work unless im standing on the ground outside...")
        player:getInventory():AddItem(pinkslip)
    else 
		local modData = pinkslip:getModData()
        local requestedVehicle = { type = modData.VehicleID }
        
        if modData.Parts then
            --This is a player created pinkslip            
            requestedVehicle.parts = modData.Parts
            --cmd = "spawnDynamicVehicle"
           -- local parts = modData.Parts
           -- for part,partData in pairs(parts) do
           -- pinkslipRecords = pinkslipRecords .. getText("IGUI_VehiclePart" .. part) .. " " .. tostring(partData.Condition) .. "%\n"
           -- end            
        else
            --This is a premade pinkslip
            if (type(modData.Condition) == "number") then
                requestedVehicle.condition = modData.Condition
            end
            if (type(modData.GasTank) == "number") then
                requestedVehicle.gastank = modData.GasTank 
            end	
            if (type(modData.TirePSI) == "number") then
                requestedVehicle.tirepsi = modData.TirePSI 
            end	
            if (type(modData.OtherTank) == "number") or (type(modData.FuelTank) == "number") then
                requestedVehicle.othertank = modData.OtherTank or modData.FuelTank
            end
            if (type(modData.Battery) == "number") then
                requestedVehicle.battery = modData.Battery
            end
            if modData.Upgraded then
                requestedVehicle.upgrade = true
            end
            --End of premade pinkslip
        end
        --End difference, both types of pinkslips do the same from here down.
        if modData.ColorH and modData.ColorS and modData.ColorV then
            requestedVehicle.color = {}
            requestedVehicle.color.h = modData.ColorH
            requestedVehicle.color.s = modData.ColorS
            requestedVehicle.color.v = modData.ColorV
        end
        if modData.BloodF or modData.BloodB or modData.BloodL or modData.BloodR then
            requestedVehicle.blood = {}
            requestedVehicle.blood.f = modData.BloodF or 0
            requestedVehicle.blood.b = modData.BloodB or 0
            requestedVehicle.blood.l = modData.BloodL or 0
            requestedVehicle.blood.r = modData.BloodR or 0
        end
        
        if (type(modData.EngineQuality) == "number") then
            requestedVehicle.enginequality = modData.EngineQuality
        end
        if modData.Rust then
            requestedVehicle.rust = modData.Rust
        end  
        if modData.Skin then
            requestedVehicle.skin = modData.Skin
        end   
        if modData.HasKey then
                requestedVehicle.makekey = true
        end
        if modData.HotWired then
                requestedVehicle.hotwire = true
        end        
        requestedVehicle.x = player:getX()
        requestedVehicle.y = player:getY()
        requestedVehicle.dir = player:getDir()
        requestedVehicle.clear = true
        sendClientCommand(player, "CW", "spawnVehicle",  requestedVehicle ) 
    end

end
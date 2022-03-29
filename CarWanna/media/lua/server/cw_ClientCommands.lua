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

    MAKE SURE YOU UNDERSTAND WHAT GNU GPL V3 IS!!!!
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

function Commands.spawnVehicle(player, args)
    print('[CarWanna]: Spawning Vehicle : '..args.type..' at '..player:getX()..' x '..player:getY()..' for '..player:getUsername())    
    local sq = getCell():getGridSquare(player:getX(), player:getY(), 0)
    local car = addVehicleDebug(args.type, IsoDirections.S, nil, sq)    
    
    --This repairs all parts on vehicles and also adds all upgrades since "missing" upgrades are parts with 0 health...    
    if args.upgrade then
        car:repair()
    end
    
    --Repair parts that actually exist on the vehicle
    if (type(args.condition) == "number") then
        for i = 0, car:getPartCount() -1 
        do
            local part = car:getPartByIndex(i)
            if part:getCondition() > 0 then
                part:setCondition(args.condition)
            end
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
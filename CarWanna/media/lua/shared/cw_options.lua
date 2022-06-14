local SETTINGS = {
  options = { 
    enablefoundloot = false,
    --foundlootrarity = 5,
    foundlootweight = 1,
    enablezedloot = false,
    zedlootrarity = 1,
    --pinkslipdamage = 1,
    blacklist = "",
  },
  names = {
    enablefoundloot = "Enable Found Loot",
    --foundlootrarity  = "Found Loot Rarity",
    foundlootweight = "Found Loot Weight",
    enablezedloot   = "Enable Zed Loot",
    zedlootrarity    = "Zed Loot Rarity",
    --pinkslipdamage  = "PinkSlip Loot Damage",
    blacklist       = "PinkSlip Black List",
  },  
  mod_blacklist = {"PinkSlip.SportsCar_ez"},
  mod_id = "CW",
  mod_shortname = "CarWanna",
  enabled = false,
}

-- Connecting the options to the menu, so user can change them.
if ModOptions and ModOptions.getInstance then
    local settings = ModOptions:getInstance(SETTINGS)
  
  	local enablefoundloot = SETTINGS.options_data.enablefoundloot
	local enablezedloot = SETTINGS.options_data.enablezedloot
    --[[
	local foundlootrarity = SETTINGS.options_data.foundlootrarity
        foundlootrarity[1] = ("0.0001")
        foundlootrarity[2] = ("0.001")
        foundlootrarity[3] = ("0.01")
        foundlootrarity[4] = ("0.1")
        foundlootrarity[5] = ("1")
        foundlootrarity[6] = ("10")
        foundlootrarity[7] = ("100")
    ]]--
	local foundlootweight = SETTINGS.options_data.foundlootweight						
        foundlootweight[1] = ("1")
        foundlootweight[2] = ("5")						
        foundlootweight[3] = ("10")							
        foundlootweight[4] = ("20")							
        foundlootweight[5] = ("50")							
        foundlootweight[6] = ("100")								        
	local zedlootrarity = SETTINGS.options_data.zedlootrarity						
        zedlootrarity[1] = ("0.0001")
        zedlootrarity[2] = ("0.001")						
        zedlootrarity[3] = ("0.01")
        zedlootrarity[4] = ("0.1")							
        zedlootrarity[5] = ("1")							
        zedlootrarity[6] = ("10")							
        zedlootrarity[7] = ("100")
   -- local pinkslipdamage = SETTINGS.options_data.pinkslipdamage
   --     pinkslipdamage[1] = ("None")
   --     pinkslipdamage[2] = ("Average")
   --     pinkslipdamage[3] = ("Random")    
    local blacklist = SETTINGS.options_data.blacklist
    
--[[
    function settings:OnApply()
      print("CarWanna User applied new options")
      ModOptions:saveIniData()
    end
]]--
    
    
  	if isClient() then
        enablefoundloot.sandbox_path = "CarWanna"
        --foundlootrarity.sandbox_path = "CarWanna"
        foundlootweight.sandbox_path = "CarWanna"
        enablezedloot.sandbox_path = "CarWanna"
        zedlootrarity.sandbox_path = "CarWanna"
    --    pinkslipdamage.sandbox_path = "CarWanna"
        blacklist.sandbox_path = "CarWanna"
    end
    
end


--Make a link
CW = CW or {} -- global variable (pick another name!)
CW.SETTINGS = SETTINGS
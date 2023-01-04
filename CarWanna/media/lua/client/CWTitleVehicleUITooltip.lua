--[[
    This file contains code by Chuckleberry Finn's Skill recovery journal 
    It has been modified to work with carwanna's player created pinkslips    
    the original source can be found here: https://github.com/ChuckTheSheep/Skill-Recovery-Journal/blob/main/Contents/mods/Skill%20Recovery%20Journal/media/lua/client/Skill%20Recovery%20Journal%20Tooltip.lua


    CarWanna, Multiplayer car spawning library for Project Zomboid. 
    Copyright (C) 2022  Xyberviri, Chuckleberry Finn
    
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

require "ISUI/ISToolTipInv"

CWTitleVehicle  = CWTitleVehicle or {}

---@param journal InventoryItem | Literature
function CWTitleVehicle.generateTooltip(pinkslip)
    local pinkSlipModData = pinkslip:getModData()    
    local pinkslipRecords = getText("IGUI_CW_Tooltip_EngineQuality") .. tostring(pinkSlipModData["EngineQuality"]).."\n"
    
    pinkslipRecords = pinkslipRecords .. getText("IGUI_CW_Tooltip_Missing")..pinkSlipModData["Missing"].."\n"
    
    pinkslipRecords = pinkslipRecords .. getText("IGUI_CW_Tooltip_Broken")..pinkSlipModData["Broken"].."\n"
    
    pinkslipRecords = pinkslipRecords .. getText("IGUI_CW_Tooltip_Skin") .. tostring(pinkSlipModData["Skin"]) .. "\n"
    
    if pinkSlipModData.HasKey then
        pinkslipRecords = pinkslipRecords .. getText("IGUI_CW_Tooltip_Key").."\n"
    end
    
    if pinkSlipModData.HotWired then
        pinkslipRecords = pinkslipRecords .. getText("IGUI_CW_Tooltip_HotWired").."\n"
    end
    
    if SandboxVars.CarWanna.ShowAllParts then
        local parts = pinkSlipModData["Parts"]
        for part,partData in pairs(parts) do
            pinkslipRecords = pinkslipRecords .. getText("IGUI_VehiclePart" .. part) .. " " .. tostring(partData.Condition) .. "%\n"
        end
    end
    
	local tooltipStart = pinkSlipModData["VehicleName"]

	return tooltipStart, pinkslipRecords
end


local function drawDetailsTooltip(tooltip, tooltipStart, skillsRecord, x, y, fontType)
	local lineHeight = getTextManager():getFontFromEnum(fontType):getLineHeight()
	local fnt = {r=0.9, g=0.9, b=0.9, a=1}
	tooltip:drawText(tooltipStart, x, (y+(15-lineHeight)/2), fnt.r, fnt.g, fnt.b, fnt.a, fontType)
	if skillsRecord then
		y=y+(lineHeight*1.5)
		tooltip:drawText(skillsRecord, x+1, (y+(15-lineHeight)/2), fnt.r, fnt.g, fnt.b, fnt.a, fontType)
	end
end

local fontDict = { ["Small"] = UIFont.NewSmall, ["Medium"] = UIFont.NewMedium, ["Large"] = UIFont.NewLarge, }
local fontBounds = { ["Small"] = 28, ["Medium"] = 32, ["Large"] = 42, }


local function ISToolTipInv_render_Override(self,hardSetWidth)
	if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then
		local mx = getMouseX() + 24
		local my = getMouseY() + 24
		if not self.followMouse then
			mx = self:getX()
			my = self:getY()
			if self.anchorBottomLeft then
				mx = self.anchorBottomLeft.x
				my = self.anchorBottomLeft.y
			end
		end

		self.tooltip:setX(mx+11)
		self.tooltip:setY(my)
		self.tooltip:setWidth(50)
		self.tooltip:setMeasureOnly(true)
		self.item:DoTooltip(self.tooltip)
		self.tooltip:setMeasureOnly(false)

		local myCore = getCore()
		local maxX = myCore:getScreenWidth()
		local maxY = myCore:getScreenHeight()
		local tw = self.tooltip:getWidth()
		local th = self.tooltip:getHeight()

		self.tooltip:setX(math.max(0, math.min(mx + 11, maxX - tw - 1)))
		if not self.followMouse and self.anchorBottomLeft then
			self.tooltip:setY(math.max(0, math.min(my - th, maxY - th - 1)))
		else
			self.tooltip:setY(math.max(0, math.min(my, maxY - th - 1)))
		end

		self:setX(self.tooltip:getX() - 11)
		self:setY(self.tooltip:getY())
		self:setWidth(hardSetWidth or (tw + 11))
		self:setHeight(th)

		if self.followMouse then
			self:adjustPositionToAvoidOverlap({ x = mx - 24 * 2, y = my - 24 * 2, width = 24 * 2, height = 24 * 2 })
		end

		self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
		self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
		self.item:DoTooltip(self.tooltip)
	end
end

local ISToolTipInv_render = ISToolTipInv.render
function ISToolTipInv:render()
	if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then
		local itemObj = self.item
		if itemObj and itemObj:getType() == "AutoTitle" then

			local tooltipStart, skillsRecord = CWTitleVehicle.generateTooltip(itemObj)

			local font = getCore():getOptionTooltipFont()
			local fontType = fontDict[font] or UIFont.Medium
			local textWidth = math.max(getTextManager():MeasureStringX(fontType, itemObj:getName()),getTextManager():MeasureStringX(fontType, skillsRecord))
                  --textWidth = math.max(textWidth, getTextManager():MeasureStringX(fontType, itemObj:getName())
			local textHeight = getTextManager():MeasureStringY(fontType, tooltipStart)

			if skillsRecord then textHeight=textHeight+getTextManager():MeasureStringY(fontType, skillsRecord)+8 end

			local journalTooltipWidth = textWidth+fontBounds[font]
			ISToolTipInv_render_Override(self,journalTooltipWidth)

			local tooltipY = self.tooltip:getHeight()-1

			self:setX(self.tooltip:getX() - 11)
			if self.x > 1 and self.y > 1 then
				local yoff = tooltipY + 8
				local bgColor = self.backgroundColor
				local bdrColor = self.borderColor

				self:drawRect(0, tooltipY, journalTooltipWidth, textHeight + 8, math.min(1,bgColor.a+0.4), bgColor.r, bgColor.g, bgColor.b)
				self:drawRectBorder(0, tooltipY, journalTooltipWidth, textHeight + 8, bdrColor.a, bdrColor.r, bdrColor.g, bdrColor.b)
				drawDetailsTooltip(self, tooltipStart, skillsRecord, 15, yoff, fontType)
				yoff = yoff + 12
			end
		else
			ISToolTipInv_render(self)
		end
	end
end
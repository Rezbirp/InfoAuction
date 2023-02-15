script_name("InfoAuction")
script_version("2.3.1")
script_author("Rezbirp")
script_dependencies("mimgui; samp events; fAwesome6; LuaSocket; ssl.https; cjson; ltn12")

--[[
Contact me:

VK/TG - Rezbirp
Discord - Evgen#1915

--------------------------------------------------------------------------------------

Стиль/Тема: https://www.blast.hk/threads/25442/page-2#post-644677
Поиск икнок украл с скрипта fa6test: https://www.blast.hk/threads/151050/#post-1151700
]]
require 'lib.moonloader'
local sampev = require 'lib.samp.events'
local imgui = require 'mimgui'
local inicfg = require 'inicfg'
local fa = require 'fAwesome6_solid'
local ffi = require 'ffi'

------------------
local cjson = require("cjson")
local https = require("ssl.https")
local ltn12 = require("ltn12")
------------------

local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local renderWindowMap = imgui.new.bool(false)
local renderWindowSettings = imgui.new.bool(false)
local renderWindowLeftInfo = imgui.new.bool(false)
local Search = imgui.new.char[128]('')

local sw, sh = getScreenResolution()
local imguiWindowSize = sh*0.95
local imguiImageSize = imguiWindowSize -16

local iconPosScale = imguiImageSize/100

local directIni = "InfoAuction\\config.ini"
local fullDirectIni = "moonloader\\config\\InfoAuction\\config.ini"
local directPhoto = "moonloader/resource/images/map.jpg"
local directToPhoto = "moonloader/resource/images"

local mainIni = {}
local houseIni = {}
local businessIni = {}

local idDialogHouseAuction = 0
local idDialogBusinessAuction = 0

local notFoundBusiness = {}
local notFoundHouse = {}

local colorHovered = imgui.ImVec4(1.00, 0.98, 0.29, 1)

local settings = {}
local nameMyServer
local serverFinded = true

local businessHoveredInLeftInfo = -1
local houseHoveredInLeftInfo = -1

function apply_custom_style() -- https://www.blast.hk/threads/25442/page-2#post-644677
    imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2
	
	colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 0.78)
	colors[clr.TextDisabled]         = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
	colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
	colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
	colors[clr.TitleBg]              = ImVec4(0.53, 0.20, 0.16, 0.65)
	colors[clr.TitleBgActive]        = ImVec4(0.56, 0.14, 0.14, 1.00)
	colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
	colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
	colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
	colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
	colors[clr.CheckMark]            = ImVec4(1.00, 0.28, 0.28, 1.00)
	colors[clr.SliderGrab]           = ImVec4(0.64, 0.14, 0.14, 1.00)
	colors[clr.SliderGrabActive]     = ImVec4(1.00, 0.37, 0.37, 1.00)
	colors[clr.Button]               = ImVec4(0.59, 0.13, 0.13, 1.00)
	colors[clr.ButtonHovered]        = ImVec4(0.95, 0.23, 0.23, 1.00)
	colors[clr.ButtonActive]         = ImVec4(1.00, 0.29, 0.29, 1.00)
	colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
	colors[clr.HeaderHovered]        = ImVec4(0.98, 0.38, 0.26, 0.80)
	colors[clr.HeaderActive]         = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
	colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
	colors[clr.ResizeGrip]           = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]    = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	
	localChatMessageScript("Запущен!")
	
	local ip, _ = sampGetCurrentServerAddress()
	
	
	--GET name server
	----------------
	local dataAllServer = https.request("https://arizona-ping.react.group/desktop/ping/Arizona/ping.json")
	local parsedAllServer = cjson.decode(dataAllServer)
	
	for i, querys in ipairs(parsedAllServer.query) do
		if querys.ip == ip then
			nameMyServer = querys.name
		end
	end
	if nameMyServer == nil then
		serverFinded = false
		localChatMessageScript("Не удалось распознать сервер. Используйте команду: /iauction [название сервера]")
	else
		localChatMessageScript("Сервер определён как: {FFFFE0}\"" .. nameMyServer.."\"")
		if not createAllConfig(nameMyServer) then
			localChatMessageScript("Не удалось найти информацию, о домах и бизнесах на этом сервере.")
			localChatMessageScript("Свяжитесь с автором. Discord: Evgen#1915, TG\\VK: @Rezbirp")
		end
	end
	
	sampRegisterChatCommand("iauction", cmdIauction)
	
	addEventHandler('onWindowMessage', function(msg, wparam, lparam)
				if wparam == 27 then
					if renderWindowMap[0] then
						if msg == 0x0100 then
							consumeWindowMessage(true, false)
						end
						if msg == 0x0101 then
							renderWindowMap[0] = false
							renderWindowSettings[0] = false
							renderWindowLeftInfo[0] = false
							houseHoveredInLeftInfo = -1
							businessHoveredInLeftInfo = -1
							infoHouse=nil
							infoBusiness=nil
						end
					end
				end
    end)
	local f = io.open(directPhoto, "r")
	if not f then
		downloadImage()
	else
		io.close(f)
	end
	
	while true do
		wait(0)
		--Закрыл таким способом, что-бы не было бага в textdraw'е
		if sampIsDialogActive() and (sampGetDialogCaption() == "{BFBBBA}Дома на аукционе" or sampGetDialogCaption() == "{BFBBBA}Бизнесы на аукционе") and (sampGetCurrentDialogId() == idDialogHouseAuction or sampGetCurrentDialogId() == idDialogBusinessAuction) and serverFinded then
			sampCloseCurrentDialogWithButton(0)
		end
	end
end

function downloadImage()

	if not doesDirectoryExist(directToPhoto) then
		createDirectory(directToPhoto)
	end

	local file = io.open(directPhoto, "wb")
	https.request{
		url = "https://i.imgur.com/qSy1UJ2.jpg",
		sink = ltn12.sink.file(file)
	}
	file = nil
end

function checkServerName(nameServer)
	nameServer = string.gsub(string.lower(nameServer), " ", "-")
	local data = https.request("https://arz.deno.dev/tools/map/"..nameServer)
	local parsed = cjson.decode(data)
	return parsed["ok"], parsed
end



function createMainSetings(parsed)
	local f = io.open(fullDirectIni, "r")
	if not f then
		mainIni = {}
		
		mainIni[0] = {icon = fa.CIRCLE_QUESTION, a = 1, r = 1, g = 0, b = 0, show = true, name = u8"Дом"}
		for i, business in ipairs(parsed.map.businesses) do
			local nameBiz = u8:decode(business.name)
			for j = 0, #mainIni do 
				if mainIni[j].name == u8(nameBiz) then
					break
				end
				
				if j == #mainIni then
					mainIni[#mainIni+1] = {icon = fa.CIRCLE_QUESTION, a = 1, r = 1, g = 0, b = 0, show = true, name = u8(nameBiz)}
				end
				
			end
		end
		
		if inicfg.save(mainIni, directIni) then
			localChatMessageScript("Создан новый конфиг.")
			localChatMessageScript("Советуем его настроить: кнопка сверху справа (на карте).")
		end
		
	else
		mainIni = inicfg.load(nil, directIni)
		io.close(f)
	end
end


function createSettings()
	for i = 0, #mainIni do
		settings[i] = {icon = mainIni[i]["icon"],a = mainIni[i]["a"], r = mainIni[i]["r"],g = mainIni[i]["g"], b = mainIni[i]["b"], show = imgui.new.bool(mainIni[i]["show"]), name = mainIni[i]["name"]}
	end
end


function createHouseIni(parsed)
	
	
	for i, house in ipairs(parsed.map.houses) do
		houseIni[house.id-1] = {x = house.x, y = house.y}
	end
	
end

function createBussinessIni(parsed)

	local tempConfigToTestIdBiz = {}
	for i = 1, #mainIni do
		tempConfigToTestIdBiz[mainIni[i].name] = i;
	end
	
	parsed.map.businesses[#parsed.map.businesses+1] = {id = 242, name = u8"Нефтевышка", x = 60.48, y = 0.5}
	parsed.map.businesses[#parsed.map.businesses+1] = {id = 245, name = u8"Нефтевышка", x = 0.5, y = 54.08}
	parsed.map.businesses[#parsed.map.businesses+1] = {id = 247, name = u8"Нефтевышка", x = 99.5, y = 54.72}
	parsed.map.businesses[#parsed.map.businesses+1] = {id = 248, name = u8"Нефтевышка", x = 52.2, y = 0.5}
	parsed.map.businesses[#parsed.map.businesses+1] = {id = 249, name = u8"Нефтевышка", x = 32.16, y = 98.5}
	
	for i, business in ipairs(parsed.map.businesses) do
		if tempConfigToTestIdBiz[business.name] ~=nil then
			businessIni[business.id-1] = {x = business.x, y = business.y, type = tempConfigToTestIdBiz[business.name]}
		else
			mainIni[#mainIni+1] = {icon = fa.CIRCLE_QUESTION, a = 1, r = 1, g = 0, b = 0, show = true, name = business.name}
			businessIni[business.id-1] = {x = business.x, y = business.y, type = #mainIni}
			tempConfigToTestIdBiz[mainIni[#mainIni]["name"]] = #mainIni
		end
		inicfg.save(mainIni, directIni)
	end

end

function createAllConfig(nameServer)
	local ok, data = checkServerName(nameServer)
	if ok then
		createMainSetings(data)
		createHouseIni(data)
		createBussinessIni(data)
		createSettings()
		serverFinded = true
		return true
	end
	return false
end

function cmdIauction(arg)
	if arg~="" then
		if createAllConfig(arg) then
			localChatMessageScript("{7CFC00}Удалось {FFFFFF}создать конфиг для: \"" .. arg.."\"")
		else
			localChatMessageScript("{FF0000}Не удалось {FFFFFF}создать конфиг для: \"" .. arg .. "\"")
		end
end
end

function localChatMessageScript(text)
	sampAddChatMessage("[InfoAuction v".. thisScript().version .."]: {FFFAFA}"..text, 0xae2121)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if serverFinded then
		if(dialogId == idDialogHouseAuction and title == "{BFBBBA}Дома на аукционе") then
			renderWindowMap[0] = true
			infoHouse = dialogInfoAuction(text)
			functionSortId(0)
		end
		if(dialogId == idDialogBusinessAuction and title == "{BFBBBA}Бизнесы на аукционе") then
			renderWindowMap[0] = true
			infoBusiness = dialogInfoAuction(text)
			functionSortId(0)
		end
	end
end

function dialogInfoAuction(lines)
	local result = {}
	local i = 1
	local k = 1
	local first = true
	local line = ""
	while i< lines:len() do

		if string.find(lines, "\n",i) then
			k=i
			i = string.find(lines, "\n",i) + 1
			line = lines:sub(k, i-2)
		else
			k=i
			i = lines:len()
			line = lines:sub(k, i)
		end

		if first then
			first = false
			goto continue
		end
		
		line = string.gsub(string.gsub(string.gsub(line, ",", ""),"\t", " "), "%.","")
		
		local type, id, timeToEnd, currentCost, minUpBid, typeMoney = parsedLine(line)
		if type == 0 or type == 1 then
			result[#result+1] = {id, timeToEnd, currentCost, minUpBid, typeMoney}
			result[#result]["id"], result[#result]["timeToEnd"], result[#result]["currentCost"], result[#result]["minUpBid"], result[#result]["typeMoney"] = tonumber(id), timeToEnd, currentCost, minUpBid, typeMoney
		else
			localChatMessageScript(line)
			localChatMessageScript("Ошибка парсинга диалога. Свяжитесь с автором.")
		end
		::continue::
	end
	return result
end


function parsedLine(line)
	--type -1 = notFound | 0 = biz |  1 = house
	
	local type, id, timeToEnd, currentCost, minUpBid, typeMoney  = -1
	if line:find("^Бизнес №%d+ (.-) %d+[%$BTCASC]- %d+[%$BTCASC]-$") then
		type = 0
		id, timeToEnd, currentCost, minUpBid, typeMoney = line:match("^Бизнес №(%d+) (.-) (%d+)[%$BTCASC]- (%d+)([%$BTCASC]-)$")
	elseif line:find("^Дом №(%d+) (.-) %$(%d+) (%d+)(%$)$") then
		--Они снова не поправили баг, с отображением валюты, в диалоге домов :(
		type = 1
		id, timeToEnd, currentCost, minUpBid, typeMoney = line:match("^Дом №(%d+) (.-) %$(%d+) (%d+)(%$)$")
	end
	return type, id, timeToEnd, currentCost, minUpBid, typeMoney
end

function notFound(id, house)
	house = house or false
	
	local found = false
	
	local array = house and notFoundHouse or notFoundBusiness
	for i = 1, #array do
		if id == array[i] then
			found = true
			break
		end
	end
	
	if not found and house then
		notFoundHouse[#notFoundHouse+1] = id
		localChatMessageScript("Дом " .. id .. " не найден.")
	elseif not found then
		notFoundBusiness[#notFoundBusiness+1] = id
		localChatMessageScript("Бизнес " .. id .. " не найден.")
	end
end

function dotsInMoney(money)
	money = tostring(money)
	local result = ""
	local p = 1
	for i = #money,1, -1  do
		if (p-1)%3 == 0 and p -1 ~= 0 then
		  result = result .. "."
		end
		result = result ..money:sub(i, i)
		p = p+1
	end
	return (result:reverse())
end

function getPosCity(x, y, map)
	if map == 1 then -- LS
		return (x -34)*1.51,(y-39.6)*1.65
	elseif map == 2 then --SF
		return x*1.78, (y-24)*1.31
	elseif map == 3 then --LV
		return x, y*2.08
	else --ALL
		return x, y
	end
end

function openUrl(url)
	os.execute('start "" "' .. url .. '"')
end

imgui.OnInitialize(function()
	imgui.GetIO().IniFilename = nil
    fa.Init(14)
	img = imgui.CreateTextureFromFile(directPhoto)
	apply_custom_style()
end)


function imgui.Icon(id, x, y, text,icon, color, isBusiness)
	if (x >= 0 and y >=0) and (x <=100 and y<= 100) then
		x = x * iconPosScale
		y = y * iconPosScale
		local cursorPosX, cursorPosY = (startPosX + x-7), (startPosY + y-7)
		imgui.SetCursorPosX(cursorPosX)
		imgui.SetCursorPosY(cursorPosY)
		
		local idInvisBtn = isBusiness and tostring(id) .. "##biz" or tostring(id) .. ""
		if imgui.InvisibleButton(idInvisBtn, imgui.ImVec2(imgui.CalcTextSize(icon).x,imgui.CalcTextSize(icon).y)) then
			sampSetChatInputEnabled(true)
			if isBusiness then
				sampSetChatInputText("/findibiz " .. id)
			else
				sampSetChatInputText("/findihouse " .. id)
			end
		end
		local currentColor = color
		if imgui.IsItemHovered() then
			currentColor = colorHovered
			imgui.BeginTooltip()
				imgui.PushTextWrapPos(600)
					imgui.TextUnformatted(text)
				imgui.PopTextWrapPos()
			imgui.EndTooltip()
		else
			currentColor = color
		end

		imgui.SetCursorPosX(cursorPosX)
		imgui.SetCursorPosY(cursorPosY)
		if (isBusiness and businessHoveredInLeftInfo == id) or (not isBusiness and houseHoveredInLeftInfo == id) then
			imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPosX()-7, imgui.GetCursorPosY()-7))
			currentColor = imgui.ImVec4(0, 1, 0,1)
			imgui.SetWindowFontScale(2.0)
		end
		imgui.TextColored(currentColor, icon)
		imgui.SetWindowFontScale(1.0)
	end
end



function imgui.ImgButton(image, size, uv0, uv1, id)
	local result = false
		imgui.BeginGroup()
		local x, y = imgui.GetCursorPosX(), imgui.GetCursorPosY()
		local pos = imgui.GetCursorScreenPos()
		local color = imgui.GetStyle().Colors[imgui.Col.Button]
		if imgui.InvisibleButton(id, size) then
			result = true
		end
		if imgui.IsItemHovered() then
			color = imgui.GetStyle().Colors[imgui.Col.ButtonHovered]
		end

		imgui.SetCursorPos(imgui.ImVec2(x,y))
		imgui.Image(image, size, uv0,uv1)
		imgui.GetWindowDrawList():AddRect(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x+size.x, pos.y+size.y),imgui.ColorConvertFloat4ToU32(color),0,0,3)
		imgui.EndGroup()
	return result
end


function imgui.ButtonOpenIconStng(i)
	local result = false
		imgui.BeginGroup()
		local x, y = imgui.GetCursorPosX(), imgui.GetCursorPosY()
		local pos = imgui.GetCursorScreenPos()
		if imgui.InvisibleButton(tostring(i) .. "openIconStng", imgui.ImVec2(310,24)) then
			result = true
		end
		
		local color = imgui.GetStyle().Colors[imgui.Col.WindowBg]
		if imgui.IsItemHovered() then
			color = imgui.ImVec4(0.2,0.25,0.27,1)
		end
		
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + 310, pos.y+24), imgui.ColorConvertFloat4ToU32(color))
		imgui.SetCursorPos(imgui.ImVec2(x, y))
		imgui.Columns(2)
		imgui.SetColumnOffset(1, 30)
		imgui.TextColored(imgui.ImVec4(settings[i]["r"], settings[i]["g"], settings[i]["b"], settings[i]["a"]),settings[i]["icon"])
		imgui.NextColumn()
		imgui.SetColumnOffset(2, 250)
		imgui.Text(settings[i]["name"])
		imgui.Columns(1)
		imgui.EndGroup()
	return result
end

function imgui.SearchIcon(stngIcon)
	local iconSelectedOrExit = false
	--fa6test https://www.blast.hk/threads/151050/#post-1151700 , author: chapo
	imgui.BeginGroup()
		imgui.Spacing()
		if imgui.Button("Search in browser", imgui.ImVec2(-0.1, 24)) then
			if ffi.string(Search) ~= "" then
				openUrl("https://fontawesome.com/search?q=" ..ffi.string(Search).."&o=r&m=free&s=solid")
			else
				openUrl("https://fontawesome.com/search?o=r&m=free&s=solid")
			end
		end
		
		imgui.InputTextWithHint('##Search','Search (by chapo)', Search, ffi.sizeof(Search))
		imgui.SameLine()
		if imgui.Button("Exit##exitSearchIcon", imgui.ImVec2(-0.1, 20)) then
			iconSelectedOrExit = true
		end
		--230
			
		imgui.Spacing()
		for k, v in pairs(fa) do
			if type(v) == 'string' and (#ffi.string(Search) == 0 or k:lower():find(ffi.string(Search):lower())) then
				local x,y = imgui.GetCursorPosX(), imgui.GetCursorPosY()
				local pos = imgui.GetCursorScreenPos()
				--btn
				if imgui.InvisibleButton(k.."selectedIcon", imgui.ImVec2(300,24)) then
					settings[stngIcon]["icon"] = v
					iconSelectedOrExit = true
				end
				local colorBtnIcon = imgui.GetStyle().Colors[imgui.Col.WindowBg]
				if imgui.IsItemHovered() then
					colorBtnIcon = imgui.ImVec4(0.2,0.25,0.27,1)
				end
				
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + 300, pos.y+24), imgui.ColorConvertFloat4ToU32(colorBtnIcon))
				imgui.SetCursorPos(imgui.ImVec2(x,y))
				--btn end
				
				imgui.Columns(2)
				imgui.SetColumnOffset(1, 40)
				imgui.SetCursorPos(imgui.ImVec2(x, y+4))
				imgui.Text(v)
				imgui.NextColumn()
				imgui.SetColumnOffset(2, 330)
				imgui.Text(k)
				imgui.Columns(1)

				imgui.Spacing()
				
			end
		end
		
	imgui.EndGroup()
	return iconSelectedOrExit
end

function imgui.TitleStngIcon(selectIcon)
	imgui.BeginGroup()
		imgui.Spacing()
			--set only icon
		if selectIcon then
		
			imgui.Columns(2)
			imgui.SetColumnOffset(1, 40)
			imgui.Text("Icon")
			imgui.NextColumn()
			imgui.SetCursorPosX(imgui.GetCursorPosX() + (250 - imgui.CalcTextSize("Name").x)/2)
			imgui.Text("Name")
			imgui.Columns(1)
			--menu current icon(name, color, show)
		else
			imgui.Columns(4)
			imgui.SetColumnOffset(1, 40)
			imgui.Text("Icon")
			imgui.NextColumn()
			imgui.SetColumnOffset(2, 240)
			imgui.SetCursorPosX(imgui.GetCursorPosX() + (170 - imgui.CalcTextSize("Name / Exit").x)/2)
			imgui.Text("Name / Exit")
			imgui.NextColumn()
			imgui.SetColumnOffset(3, 285)
			imgui.Text("Color")
			imgui.NextColumn()
			imgui.Text("Show")
			imgui.Columns(1)
		end
	imgui.EndGroup()
end

function imgui.TitleExemple(stngIcon, selectIcon)
	local icon = false
	local exit = false
	imgui.BeginGroup()
		if not selectIcon then
			local x,y = imgui.GetCursorPosX(), imgui.GetCursorPosY()
			local pos = imgui.GetCursorScreenPos()
			--menu 
			imgui.Spacing()
			imgui.Columns(4)
			--set icon
			imgui.SetCursorPosY(y+4)
			if imgui.InvisibleButton(tostring(stngIcon) .. "iconSet", imgui.ImVec2(40,28)) then
				icon = true
			end
			local colorBtnIcon = imgui.GetStyle().Colors[imgui.Col.WindowBg]
			if imgui.IsItemHovered() then
				colorBtnIcon = imgui.ImVec4(0.2,0.25,0.27,1)
			end
			
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(pos.x, pos.y+4), imgui.ImVec2(pos.x + 40, pos.y+28), imgui.ColorConvertFloat4ToU32(colorBtnIcon))
			imgui.SetCursorPos(imgui.ImVec2(x, y+4))
			imgui.SetColumnOffset(1, 40)
			imgui.Text(settings[stngIcon]["icon"])
			
			
			
			imgui.NextColumn()
			
			
			--exit
			local x,y = imgui.GetCursorPosX(), imgui.GetCursorPosY()
			local pos = imgui.GetCursorScreenPos()
			imgui.SetCursorPosX(x-6)
			if imgui.InvisibleButton(tostring(stngIcon) .. "iconExit", imgui.ImVec2(240,24)) then
				exit = true
			end
			local colorBtnExit = imgui.GetStyle().Colors[imgui.Col.WindowBg]
			if imgui.IsItemHovered() then
				colorBtnExit = imgui.ImVec4(0.2,0.25,0.27,1)
			end
			
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(pos.x-6, pos.y), imgui.ImVec2(pos.x + 240, pos.y+24), imgui.ColorConvertFloat4ToU32(colorBtnExit))
			imgui.SetCursorPos(imgui.ImVec2(x, y))
			imgui.SetColumnOffset(2, 240)
			imgui.Text(settings[stngIcon]["name"])
			imgui.NextColumn()
			
			
			
			--set color
			imgui.SetColumnOffset(3, 285)
			local color = imgui.new.float[4](settings[stngIcon]["r"], settings[stngIcon]["g"], settings[stngIcon]["b"], settings[stngIcon]["a"])
			imgui.ColorEdit4(settings[stngIcon]["name"], color, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel)
			settings[stngIcon]["r"] = color[0]
			settings[stngIcon]["g"] = color[1]
			settings[stngIcon]["b"] = color[2]
			settings[stngIcon]["a"] = color[3]
			imgui.NextColumn()
			--show
			imgui.Checkbox("##"..tostring(stngIcon),settings[stngIcon]["show"])
			imgui.Columns(1)
		end
	imgui.EndGroup()
	return icon, exit
end

function imgui.MenuSettingIcon(stngIcon, selectIcon)
	local icon = false
	local exit = false
		imgui.BeginGroup()
		imgui.TitleStngIcon(selectIcon)
	
		icon, exit = imgui.TitleExemple(stngIcon, selectIcon)
		if selectIcon then
			--fa6test https://www.blast.hk/threads/151050/#post-1151700 , author: chapo
			if imgui.SearchIcon(stngIcon) then
				icon = true
			end
		else
			--exemple
			--city
			local colorIcon = imgui.ImVec4(settings[stngIcon]["r"], settings[stngIcon]["g"], settings[stngIcon]["b"], settings[stngIcon]["a"])
			local posY = imgui.GetCursorPosY()
			imgui.SetCursorPos(imgui.ImVec2((330-13-150-imgui.GetCursorPosX())/2, imgui.GetCursorPosY()+20))
			imgui.Image(img, imgui.ImVec2(150,150), imgui.ImVec2(822/1250,864/1250), imgui.ImVec2((822+150)/1250, (864+150)/1250))
			local posYAfterImg = imgui.GetCursorPosY()
			imgui.SetCursorPos(imgui.ImVec2((330-13-imgui.GetCursorPosX())/2, posY+95))
			imgui.TextColored(colorIcon, settings[stngIcon]["icon"])
			--desert
			imgui.SetCursorPosY(posYAfterImg)
			posY = imgui.GetCursorPosY()
			imgui.SetCursorPos(imgui.ImVec2((330-13-150-imgui.GetCursorPosX())/2, imgui.GetCursorPosY()+20))
			imgui.Image(img, imgui.ImVec2(150,150), imgui.ImVec2(529/1250,349/1250), imgui.ImVec2((529+150)/1250, (349+150)/1250))
			posYAfterImg = imgui.GetCursorPosY()
			imgui.SetCursorPos(imgui.ImVec2((330-13-imgui.GetCursorPosX())/2, posY+95))
			imgui.TextColored(colorIcon, settings[stngIcon]["icon"])
			
			--forest
			imgui.SetCursorPosY(posYAfterImg)
			posY = imgui.GetCursorPosY()
			imgui.SetCursorPos(imgui.ImVec2((330-13-150-imgui.GetCursorPosX())/2, imgui.GetCursorPosY()+20))
			imgui.Image(img, imgui.ImVec2(150,150), imgui.ImVec2(390/1250,720/1250), imgui.ImVec2((390+150)/1250, (720+150)/1250))
			posYAfterImg = imgui.GetCursorPosY()
			imgui.SetCursorPos(imgui.ImVec2((330-13-imgui.GetCursorPosX())/2, posY+95))
			imgui.TextColored(colorIcon, settings[stngIcon]["icon"])
			--SAVE
			imgui.SetCursorPosY(imgui.GetWindowHeight() - 35)
			imgui.SetCursorPosX((310 - 200) * 0.5)
			if imgui.Button(fa.FLOPPY_DISK .. u8" Сохранить", imgui.ImVec2(200, 25)) then
				mainIni[stngIcon] = {name = settings[stngIcon]["name"],icon = settings[stngIcon]["icon"], a = settings[stngIcon]["a"], r = settings[stngIcon]["r"], g = settings[stngIcon]["g"], b = settings[stngIcon]["b"], show = settings[stngIcon]["show"][0]}
				if inicfg.save(mainIni, directIni) then
					localChatMessageScript("Сохранено")
				end
			end
		end
		
		imgui.EndGroup()
	return icon, exit
			
end



local menu = 0
local map = 0 --0 ALL | 1 LS | 2 SF | 3 LV
local stngIcon = 0
local selectIcon = false



local newFrameSettings = imgui.OnFrame(
	function() return renderWindowSettings[0] end,
	function(player)
		imgui.SetNextWindowSize(imgui.ImVec2(330, imguiWindowSize), imgui.Cond.FirstUseEver)
		
		local posWndX = (sw/2+imguiWindowSize/2)
		local posWndX = (renderWindowSettings[0] and not renderWindowLeftInfo[0]) and posWndX - 165 or posWndX
		imgui.SetNextWindowPos(imgui.ImVec2(posWndX, (sh*0.05)/2))
		
		imgui.Begin("Settings##Bgn",renderWindowSettings, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		if imgui.Button(fa.MAP .. " Map", imgui.ImVec2(150, 20)) then
			menu = 0
		end
		imgui.SameLine()
		if imgui.Button(fa.CIRCLE_QUESTION .. " Icons##", imgui.ImVec2(150, 20)) then
			stngIcon=-1
			selectIcon=false
			menu = 1
		end	
		
		--set city
		if menu == 0 then
		
			imgui.Spacing()
			imgui.SetCursorPosX((285 - imgui.CalcTextSize("All").x)/2)
			imgui.Text("All")
			if imgui.ImgButton(img, imgui.ImVec2(300, 300),imgui.ImVec2(0, 0), imgui.ImVec2(1,1), "##ALL") then
				map = 0
			end
			imgui.Spacing()
			imgui.SetCursorPosX((285 - imgui.CalcTextSize("Los Santos").x)/2)
			imgui.Text("Los Santos")
			if imgui.ImgButton(img, imgui.ImVec2(300, 300),imgui.ImVec2(425/1250, 495/1250), imgui.ImVec2(1,1), "##LS") then
				map = 1
			end
			imgui.Spacing()
			imgui.SetCursorPosX((285 - imgui.CalcTextSize("San Fierro").x)/2)
			imgui.Text("San Fierro")
			if imgui.ImgButton(img, imgui.ImVec2(300, 300),imgui.ImVec2(0, 300/1250), imgui.ImVec2(700/1250,1), "##SF") then
				map = 2
			end
			imgui.Spacing()
			imgui.SetCursorPosX((285 - imgui.CalcTextSize("Las Venturas").x)/2)
			imgui.Text("Las Venturas")
			if imgui.ImgButton(img, imgui.ImVec2(300, 300),imgui.ImVec2(0, 0), imgui.ImVec2(1, 600/1250), "##LV") then
				map = 3
			end
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(600)
					imgui.TextUnformatted(u8("Простите за качество :("))
				imgui.PopTextWrapPos()
			imgui.EndTooltip()
			end
		--All selection icon
		elseif menu == 1 then
			imgui.Spacing()
			for i = 0, #settings do
				if imgui.ButtonOpenIconStng(i) then
					stngIcon = i
					menu = 2
				end	
			end
		elseif menu == 2 then
			
			local icon, exit = imgui.MenuSettingIcon(stngIcon, selectIcon)
			if exit then
				menu = 1
			end
			if icon then
				selectIcon = not selectIcon
			end
			
		end
		imgui.End()
	end
)

local newFrameMap = imgui.OnFrame(
    function() return renderWindowMap[0] end,
	function(player)
		imgui.SetNextWindowSize(imgui.ImVec2(imguiWindowSize, imguiWindowSize), imgui.Cond.FirstUseEver)
		
		local posWndX = sw/2
		if renderWindowSettings[0] and not renderWindowLeftInfo[0] then
			posWndX = posWndX - 165
		elseif renderWindowLeftInfo[0] and not renderWindowSettings[0] then
			posWndX = posWndX + 160
		end
		imgui.SetNextWindowPos(imgui.ImVec2(posWndX, (sh/2)), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin("MAP##Bgn",renderWindowMap, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
			startPosX = imgui.GetCursorPosX()
			startPosY = imgui.GetCursorPosY()
			
			
			--ALL
			if map == 0 then
				imgui.Image(img, imgui.ImVec2(imguiImageSize, imguiImageSize))
			elseif map == 1 then
			--LS
			imgui.Image(img, imgui.ImVec2(imguiImageSize, imguiImageSize), imgui.ImVec2(425/1250, 495/1250), imgui.ImVec2(1,1))
			elseif map == 2 then
			--SF
			imgui.Image(img, imgui.ImVec2(imguiImageSize, imguiImageSize), imgui.ImVec2(0, 300/1250), imgui.ImVec2(700/1250,1))
			else
			--LV
				imgui.Image(img, imgui.ImVec2(imguiImageSize, imguiImageSize), imgui.ImVec2(0, 0), imgui.ImVec2(1, 600/1250))
			end
			
			--Icon house
			if infoHouse~=nil then
				for i,v in pairs(infoHouse) do
					if houseIni[v.id] ~= nil and houseIni[v.id].x ~=nil and houseIni[v.id].y ~= nil then
						if settings[0]["show"][0] then
							local type = settings[0]
							local text =u8"Дом №" ..v.id ..u8" | До завершения: "..v.timeToEnd..u8"\nТекущая цена: " .. dotsInMoney(v.currentCost) .." ".. v.typeMoney .. u8" | Мин. ставка: " ..dotsInMoney(v.minUpBid).." "..v.typeMoney
							local x, y = getPosCity(tonumber(houseIni[v.id].x), tonumber(houseIni[v.id].y),map)
							imgui.Icon(v.id, x,y, text, type["icon"], imgui.ImVec4(type["r"], type["g"], type["b"], type["a"]), false)
						end
					else
						notFound(v.id, true)
					end
				end
			end
			
			--icon biz
			if infoBusiness ~=nil then
				for i,v in pairs(infoBusiness) do
					if businessIni[v.id] ~= nil and businessIni[v.id].x ~= nil and businessIni[v.id].y ~= nil and businessIni[v.id].type ~=nil then
						if settings[tonumber(businessIni[v.id].type)]["show"][0] then
							local type = settings[tonumber(businessIni[v.id].type)]
							local text = u8"Бизнес №" ..v.id ..u8" | Тип: "..type["name"].. u8" | До завершения: "..v.timeToEnd..u8"\nТекущая цена: " .. dotsInMoney(v.currentCost) .." ".. v.typeMoney .. u8" | Мин. ставка: " ..dotsInMoney(v.minUpBid).." "..v.typeMoney
							local x, y = getPosCity(tonumber(businessIni[v.id].x), tonumber(businessIni[v.id].y),map)
							imgui.Icon(v.id, x,y, text, type["icon"], imgui.ImVec4(type["r"], type["g"], type["b"], type["a"]), true)
						end
					else
						notFound(v.id, false)
					end
					
				end
			end
			
			--settings
			imgui.SetCursorPos(imgui.ImVec2(startPosX+(imguiWindowSize-35), startPosY))
			if imgui.Button(fa.GEAR .. "##settingsbtn", imgui.ImVec2(20, 20)) then	
				renderWindowSettings[0] = not renderWindowSettings[0]
			end
			
			--leftInfoPanel
			imgui.SetCursorPos(imgui.ImVec2(startPosX, startPosY))
			if imgui.Button(fa.BARS_STAGGERED .. "##left info panel", imgui.ImVec2(20, 20)) then
				renderWindowLeftInfo[0] = not renderWindowLeftInfo[0]
			end
		imgui.End()
	end
)

--sortID:   0 = nil ||| 1 = id up   ||| 2 = id down
--sortTime: 0 = nil ||| 1 = time up ||| 2 = time down
--sortCost: 0 = nil ||| 1 = cost up ||| 2 = cost down

local sortId = 1
local sortTime = 0
local sortCost = 0


local newFrameLeftInfo = imgui.OnFrame(
    function() return renderWindowLeftInfo[0] end,
	function(player)
		imgui.SetNextWindowSize(imgui.ImVec2(320, imguiWindowSize),imgui.Cond.FirstUseEver)
		
		local posWndX = sw/2 - (imguiWindowSize/2 + 160)
		local posWndX = (renderWindowSettings[0] and renderWindowLeftInfo[0]) and posWndX-160 or posWndX
		imgui.SetNextWindowPos(imgui.ImVec2(posWndX, (sh*0.05)/2))
		
		imgui.Begin("LeftInfo#bgn", renderWindowLeftInfo, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		
		if infoHouse ~= nil or infoBusiness ~= nil then
			imgui.SetCursorPosX(29)
			if imgui.buttonSort("ID",fa.ARROW_UP, fa.ARROW_DOWN ,sortId, 65) then
				functionSortId(sortId)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(29 + 85)
			if imgui.buttonSort("Time",fa.ARROW_UP, fa.ARROW_DOWN ,sortTime, 50) then
				functionSortTime(sortTime)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(29 + 150)
			if imgui.buttonSort("Cost",fa.ARROW_UP, fa.ARROW_DOWN ,sortCost, 75) then
				functionSortCost(sortCost)
			end
			
		end		
		
		local isHoveredHouse = false
		if infoHouse ~= nil and imgui.TreeNodeStr("House") then
			for i =1, #infoHouse do
				 if imgui.LeftInfoBodyTreeNode(i, true) then
					isHoveredHouse=true
					houseHoveredInLeftInfo = infoHouse[i]["id"]
				end
				if not isHoveredHouse and i == #infoHouse then
					houseHoveredInLeftInfo = -1
				end
			end
			imgui.TreePop()
		else
			houseHoveredInLeftInfo = -1
		end
		
		imgui.Spacing()
		
		local isHoveredBiz = false
		if infoBusiness ~= nil and imgui.TreeNodeStr("Business") then
			for i =1, #infoBusiness do
				if imgui.LeftInfoBodyTreeNode(i) then
					isHoveredBiz=true
					businessHoveredInLeftInfo = infoBusiness[i]["id"]
				end
				if not isHoveredBiz and i == #infoBusiness then
					businessHoveredInLeftInfo = -1
				end
			end
			imgui.TreePop()
		else
			businessHoveredInLeftInfo = -1
		end
		
		imgui.End()
	end
	
)

function imgui.LeftInfoBodyTreeNode(id, isHouse)
	local result = false
		
		local text = isHouse and "Дом: " or "Бизнес: "
		local tmpId = isHouse and infoHouse[id]["id"] or infoBusiness[id]["id"]
		local timeToEnd = isHouse and infoHouse[id]["timeToEnd"] or infoBusiness[id]["timeToEnd"]
		local currentCost = isHouse and infoHouse[id]["currentCost"] or infoBusiness[id]["currentCost"]
		local typeMoney = isHouse and infoHouse[id]["typeMoney"] or infoBusiness[id]["typeMoney"]
		
		imgui.BeginGroup()
			imgui.Spacing()
			
			local x, y = imgui.GetCursorPosX(), imgui.GetCursorPosY()
			
			
			--itemHovered
			local pos = imgui.GetCursorScreenPos()
			local colorBtnIcon = imgui.GetStyle().Colors[imgui.Col.WindowBg]
			imgui.SetCursorPos(imgui.ImVec2(x,y-2))
			imgui.InvisibleButton(id .. "leftInfo" .. (isHouse and "house" or "business"), imgui.ImVec2(320,22))
			if imgui.IsItemHovered() then
				colorBtnIcon = imgui.ImVec4(0.2,0.25,0.27,1)
				result = true
				if not isHouse and businessIni[infoBusiness[id]["id"]]~=nil then
					imgui.BeginTooltip()
						imgui.PushTextWrapPos(600)
							imgui.TextUnformatted(mainIni[businessIni[infoBusiness[id]["id"]]["type"]]["name"])
						imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
			end

			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(pos.x, pos.y-2), imgui.ImVec2(pos.x + 320, pos.y+22), imgui.ColorConvertFloat4ToU32(colorBtnIcon))
			--end
			imgui.SetCursorPos(imgui.ImVec2(x,y))
			imgui.Text(u8(text)..tmpId)
			imgui.SetCursorPos(imgui.ImVec2(x+85, y))
			imgui.Text(timeToEnd)
			imgui.SetCursorPos(imgui.ImVec2(x+150, y))
			imgui.Text(dotsInMoney(currentCost) .." ".. typeMoney)
			
		imgui.EndGroup()
		return result
end


function imgui.buttonSort(name, icon1, icon2, typeIcon, sizeBtn)
	local result = false
	imgui.BeginGroup()
		if typeIcon == 1 then
			name = name .. icon1
		elseif typeIcon == 2 then
			name = name .. icon2
		end
		
		if imgui.Button(name, imgui.ImVec2(sizeBtn, 18)) then
			result = true
		end
	imgui.EndGroup()
	return result
end
--typeSortId: 0 = up || 2 = up || other = down
function functionSortId(typeSortId)
	if infoHouse~= nil then
		sortIdArray(infoHouse, typeSortId)
	end
	if infoBusiness ~= nil then
		sortIdArray(infoBusiness, typeSortId)
	end
	if typeSortId == 0 or typeSortId == 2 then
		sortId = 1
	else 
		sortId = 2
	end
	sortTime = 0
	sortCost = 0
	
end

function sortIdArray(array, typeSortId)
	table.sort(array, function(a, b)
			if typeSortId == 0 or typeSortId == 2 then
				return a.id < b.id
			end
			
			return a.id > b.id
			
		end)
end

function functionSortTime(typeSortTime)
	if infoHouse~= nil then
		sortTimeArray(infoHouse, typeSortTime)
	end
	
	if infoBusiness~= nil then
		sortTimeArray(infoBusiness, typeSortTime)
	end
	
	if typeSortTime == 0 or typeSortTime == 2 then
		sortTime = 1
	else 
		sortTime = 2
	end
	sortId = 0
	sortCost = 0
end

--ChatGPT solo <3
function sortTimeArray(array, typeSortTime)
	table.sort(array, function(a, b)
		local a_hours, a_minutes, a_seconds = a.timeToEnd:match("(%d+):(%d+):(%d+)")
		local b_hours, b_minutes, b_seconds = b.timeToEnd:match("(%d+):(%d+):(%d+)")

		if not a_hours then
			a_hours = 0
		end
		if not b_hours then
			b_hours = 0
		end
		if not a_minutes then
			a_minutes, a_seconds = a.timeToEnd:match("(%d+):(%d+)")
		end
		if not b_minutes then
			b_minutes, b_seconds = b.timeToEnd:match("(%d+):(%d+)")
		end
		
		
		a_hours, a_minutes, a_seconds = tonumber(a_hours), tonumber(a_minutes), tonumber(a_seconds)
		b_hours, b_minutes, b_seconds = tonumber(b_hours), tonumber(b_minutes), tonumber(b_seconds)
		
		if a_hours ~= b_hours then
			if typeSortTime == 1 then
				return a_hours > b_hours
			else
				return a_hours < b_hours
			end
		elseif a_minutes ~= b_minutes then
			if typeSortTime == 1 then
				return a_minutes > b_minutes
			else
				return a_minutes < b_minutes
			end
		else
			if typeSortTime == 1 then
				return a_seconds > b_seconds
			else
				return a_seconds < b_seconds
			end
		end
	end)
end


function functionSortCost(typeSortCost)
	if infoHouse~= nil then
		sortCostArray(infoHouse, typeSortCost)
	end
	if infoBusiness ~= nil then
		sortCostArray(infoBusiness, typeSortCost)
	end
	if typeSortCost == 0 or typeSortCost == 2 then
		sortCost = 1
	else 
		sortCost = 2
	end
	sortTime = 0
	sortId = 0
end

function sortCostArray(array, typeSortCost)
	table.sort(array, function(a, b)
		local a_cost, b_cost = tonumber(a.currentCost), tonumber(b.currentCost)
		if typeSortCost == 0 or typeSortCost == 2 then
			return a_cost < b_cost
		end
		
		return a_cost > b_cost
	
	end)
end
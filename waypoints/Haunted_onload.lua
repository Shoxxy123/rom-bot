-- Version 1.03

setExecutionPath(getExecutionPath().."/..")

yolius 			= 121409 			-- Yolius
tomb 			= 121407			-- Revenant Grave
bomber			= 121412 			-- Bomb Demon Pumpkin
bomberbuff		= 623500			-- Recharge Energy
prizepumpkin	= 121405			-- Strange Demon Pumpkin
spikes			= 121404			-- Needle Trap
healer			= GetIdName(121411)	-- Pumpkin Prankster
traveller 		= 121413			-- Scattered Demon Pumpkins
joker 			= GetIdName(111814) -- Hill Joker
pumpkincoin		= 209433			-- Pumpkin Coin
transportrunes	= 202903			-- Transport Runes

yoliusaccept	= getTEXT("SC_2012HALLOW_MALA_02") 	-- 'I want to take up the challenge.'
yoliusreport	= getTEXT("SC_2012HALLOW_MALA_03") 	-- 'Report results'
yoliusrepeat	= getTEXT("SC_2012HALLOW_MALA_33")	-- "I want to take up the challenge again.'
jokerready		= getTEXT("SC_2012HALLOW_MALA_09") 	-- 'Ready'
transformpot	= getTEXT("Sys204175_name")			-- Transformation Potion
piepackage		= 240741

mobs = {
   utf8ToAscii_umlauts(GetIdName(107346)), -- Cursed Devil
   utf8ToAscii_umlauts(GetIdName(107347)), -- Shadow Ghost
   utf8ToAscii_umlauts(GetIdName(107348)), -- Skeleton Spearman
}

logentry = nil
pumpcoins = inventory:itemTotalCount(pumpkincoin)

flyheight 	= 39 	-- Must be high enough to clear spikes
toomanymobs	= 2 	-- How many mobs before trying to clear them

timescompleted = 0

function checkRelog()

	if logentry == "Ran out of time" and LastTileDug then
		if LastTileDug > 36 then LastTileDug = 36 end
		logentry = logentry .. string.format(" with %d tiles remaining.", 36 - LastTileDug)
	else
		logentry = logentry .. "."
	end

	processrewards()

	-- Log result
	local filename = getExecutionPath() .. "/logs/haunted.log";
	local file, err = io.open(filename, "a+");
	if file then
		file:write("Acc: "..RoMScript("GetAccountName()").."\tName: " ..string.format("%-10s",player.Name ).." \tDate: " .. os.date() ..
		" \tCoins gained/total: "..inventory:itemTotalCount(pumpkincoin) - pumpcoins.."/".. inventory:itemTotalCount(pumpkincoin).. "\t" ..logentry .. "\n")
		file:close();
	end

	if When_Finished == "relog" then
		ChangeChar()
		rest(3000)
		loadProfile()
		loadPaths(__WPL.FileName);
	elseif When_Finished == "charlist" then
		SetCharList(CharList)
		LoginNextChar()
		loadProfile()
		loadPaths(__WPL.FileName);
	elseif When_Finished == "end" then
		error("Ending script",2)
	else
		loadPaths(When_Finished)
	end
end

--=== Function to sort tables, at angle ===--
local function NEsize(_x, _z)
   local X1 = 2622.1403808594
   local Z1 = 2900.1105957031
   local X2 = 2471.7895507813
   local Z2 = 2954.833984375

   return math.floor(((_x-X1)*(Z2-Z1)-(X2-X1)*(_z-Z1))/math.sqrt((X2-X1)^2 + (Z2-Z1)^2) + 0.5)/32
end

local function SEsize(_x, _z)
   local X1 = 2471.7895507813
   local Z1 = 2954.833984375
   local X2 = 2526.5126953125
   local Z2 = 3105.1848144531

   return math.floor(((_x-X1)*(Z2-Z1)-(X2-X1)*(_z-Z1))/math.sqrt((X2-X1)^2 + (Z2-Z1)^2) + 0.5)/32
end

local tiles
--=== Create table of tiles ===--
function createTileTable()
	local tmp = {}

	local objectList = CObjectList();
	objectList:update();
	local objSize = objectList:size()

	for i = 0,objSize do
		local obj = objectList:getObject(i);
		if obj.Id == 111811 and clicktile(obj) == true then
			table.insert(tmp, table.copy(obj))
		end
	end

	if #tmp < 3 then
		for i = 0,objSize do
			local obj = objectList:getObject(i);
			if (obj.Id == 111811 or obj.Id == 111812) and clicktile(obj) == true then
				table.insert(tmp, table.copy(obj))
			end
		end
	end

	-- sort by address
	local function addresssortfunc(a,b)
		return a.Address > b.Address
	end
	table.sort(tmp, addresssortfunc)

	-- check for duplicate addresses
	for i = #tmp - 1, 1, -1 do
		if tmp[i].Address == tmp[i+1].Address then
			print("Diplicate found. Removing.\a")
			table.remove(tmp,i)
		end
	end

	-- Create empty array
	tiles = {}

	-- Place in correct position in table array
	-- 	1  7 13 19 25 31
	-- 	2  8 14 20 26 32
	-- 	3  9 15 21 27 33
	-- 	4 10 16 22 28 34
	-- 	5 11 17 23 29 35
	-- 	6 12 18 24 30 36
	for k,v in pairs(tmp) do
		tiles[SEsize(v.X,v.Z)*6+NEsize(v.X,v.Z)+1] = v
	end
end

--=== look for indicator that the tile is clickable ===--
function clicktile(tile)
	if not tileExists(tile) then return false end

	local tmp = memoryReadRepeat("int", getProc(), tile.Address + addresses.pawnAttackable_offset) or 0;
	if bitAnd(tmp,0x8) then
		return true
	else
		return false
	end
end

function tileExists(tile)
	tile.Id = memoryReadUInt(getProc(), tile.Address + addresses.pawnId_offset) or 0;
	tile.Type = memoryReadInt(getProc(), tile.Address + addresses.pawnType_offset) or -1;

	return (tile.Id == 111811 or tile.Id == 111812) and tile.Type ~= -1 -- invalid object
end

function breaktiles()
	cprintf(cli.yellow,"Digging up tiles...\n")
	--=== Order of tiles ===--
	orderlist = {22,21,15,16,17,23,29,28,27,26,20,14,8,9,10,11,12,18,24,30,36,35,34,33,32,31,25,19,13,7,1,2,3,4,5,6}
	for i = 1,#orderlist do
		local tile = tiles[orderlist[i]]
		player:checkPotions()

		-- Dig tile
		if tile and clicktile(tile) == true then
			print("Clicking Tile "..orderlist[i])
			local breaking
			repeat repeat
				-- Failed
				if checkfailure() == true then return true end

				-- Check if don't have bomb and bomber is ready
				if not RoMScript("GetExtraActionInfo(1)") then
					local bombr = getReadyBomber()
					if bombr then
						print("Getting bomb skill from bomber")
						moveto(bombr)
						repeat
							if checkfailure() == true then return true end
							player:target(bombr.Address)
							--yrest(500)
							Attack()
							yrest(500)
						until RoMScript("GetExtraActionInfo(1)")
						break
					end
				end

				-- check if too many mobs
				if player.Battling and mobcount() >= toomanymobs then
					print("Too many mobs. Clearing.")
					killmobs()
					break
				end

				-- Check if have bomb and exists tomb
				local grave = player:findNearestNameOrId(tomb)
				if grave and RoMScript("GetExtraActionInfo(1)") then
					if distance(player,grave) > 90 then
						moveto(grave)
					end
					print("Destroying grave")
					--yrest(1000)
					player:target(grave.Address)
					yrest(500)
					RoMScript("UseExtraAction(1)")
					--yrest(1000)
					break
					
				end

				-- Move to tile
				moveto(tile)

				-- Check if still alive
				if checkfailure() == true then return true end

				for count = 1, 3 do
					player:target(tile); --yrest(300)
					Attack() yrest(500)
					player:update()
					if player.Casting then break end
				end
				repeat
					yrest(50)
					if checkfailure() == true then return true end
					player:update()
				until player.Casting == false

				breaking = false
				local starttime = os.clock()
				repeat
					yrest(100)
					local reward = findreward(tile)
					if reward then
						if reward.Id == spikes then
							teleport(player.X,player.Z,flyheight)
						end
						breaking = true
					elseif clicktile(tile) == false then
						breaking = true
					end
				until breaking or (os.clock() - starttime > 1)
			until true until breaking
			LastTileDug = LastTileDug + 1

			-- see what's there
			local starttime = os.clock()
			repeat
				local result = findreward(tile)
				if result and flyheight +5 > distance(player.X,player.Z,result.X,result.Z) then
					result = CPawn(result.Address)
					printf("%s found. Id %d.\n", result.Name, result.Id)
					if result.Id == prizepumpkin then
						teleport(result.X+1,result.Z+1,18)
						repeat
							player:target(result.Address)
							--yrest(500)
							Attack()
							yrest(500)
							if checkfailure() == true then return true end
							result:update()
						until not result:exists() or isFading(result)
					elseif result.Id == bomber then
						if not RoMScript("GetExtraActionInfo(1)") then
							teleport(result.X+1,result.Z+1,18)
							repeat
								if checkfailure() == true then return true end
								player:target(result.Address)
								--yrest(500)
								Attack()
								yrest(500)
							until RoMScript("GetExtraActionInfo(1)")
						end
					elseif result.Id == tomb then
						if RoMScript("GetExtraActionInfo(1)") then
							player:target(result.Address)
							yrest(500)
							RoMScript("UseExtraAction(1)")
							yrest(500)
						end
					end
					teleport(player.X,player.Z,flyheight)
					break
				end
			until os.clock() - starttime > 1
		end
	end
end

function mobcount(range)
	local function isMob(obj)
		for k,v in pairs(mobs) do
			if obj.Name == v and not isFading(obj) then
				if range == nil or range >= distance(player,obj) then
					local targetPtr = memoryReadRepeat("uint", getProc(), obj.Address + addresses.pawnTargetPtr_offset) or 0
					if targetPtr > 0 then
						return true
					end
				end
			end
		end
		return false
	end
	local count = 0
	local olist = CObjectList() olist:update()
	for k,v in pairs(olist.Objects) do
		if isMob(v) then
			count = count + 1
		end
	end
	return count
end

function getReadyBomber()
	local olist = CObjectList() olist:update()
	for k,v in pairs(olist.Objects) do
		if v.Id == bomber then
			local b = CPawn(v.Address)
			if not b:hasBuff(bomberbuff) then
				return b
			end
		end
	end
end

function moveto(pos)
	if fly then fly() end
	player:updateXYZ()
	if distance(player, pos) > 10 then
		if teleport then
			teleport(pos.X+1,pos.Z+1,18)
		else
			player:moveTo(pos,true)
		end
	end
	player:update()
	player:waitTillStopMoving()
end

function isFading(pawn)
	return memoryReadRepeat("float", getProc(), pawn.Address + addresses.pawnFading_offset) ~= 0
end

function nearestEdgeTile()
	local edgetiles = {1,2,3,4,5,6,12,18,24,30,36,35,34,33,32,31,25,19,13,7}
	player:updateXYZ()
	local found
	local bestdist = math.huge
	for k,n in pairs(edgetiles) do
		if tiles[n] and not closespikes(tiles[n]) and bestdist > distance(player,tiles[n]) then
			bestdist = distance(player,tiles[n])
			found = tiles[n]
		end
	end
	return found
end

function killmobs()
	local edge = nearestEdgeTile()
	if not edge then
		error("no edge tiles")
	end
	moveto(edge)

	-- wait for mobs to come in range
	repeat
		if checkfailure() == true then return end
		player:checkPotions()
		yrest(1000)
	until mobcount() == mobcount(100)

	-- wait for traveller
	repeat
		if checkfailure() == true then return end
		local trav = player:findNearestNameOrId(traveller)
		if trav and 20 > distance(player,trav) then
			player:target(trav.Address)
			Attack() yrest(75) Attack() yrest(75) Attack()
			yrest(1000)
		end
		yrest(100)
	until toomanymobs > mobcount(100)
end

function checkfailure()
	player:update()
	if not isInGame() then
		print("Out of time")
		repeat
			yrest(1000)
		until isInGame()
		yrest(3000)
		player:update()
		return true
	elseif (player.HP < 1 or player.Alive == false) then
		print("Player died.")
		logentry = "Player died."
		return true
	elseif not RoMScript("TimeKeeperFrame:IsVisible()") then
		print("Out of time")
		return false
	end
end

function closespikes(tile)
	local found
	local bestdist = math.huge
	local olist = CObjectList() olist:update()
	for k,v in pairs(olist.Objects) do
		if v.Id == spikes and distance(tile,v) < 15 then
			return true
		end
	end
end

function disableallskills()
	settings.profile.skills = {}
end

function findreward(tile)
	local found
	local bestdist = math.huge
	local olist = CObjectList() olist:update()
	for k,v in pairs(olist.Objects) do
		if v.Id == spikes or v.Id == tomb or v.Id == bomber or v.Id == prizepumpkin or v.Id == healer then
			if distance(tile,v) < 25 then
				return v
			end
		end
	end
end

function isbageval(item)
	if string.find(item.Name,transformpot,1,true) then -- Transormation Potions
		return (item.ItemShopItem and Transform_Pots_To_IS_Bag == true)
	elseif item.Id >= 205547 and item.Id <= 205550 then -- 7 day backpack tickets
		return Backpack_Ticket_To_IS_Bag == true
	elseif item.ObjType == 3 and 						-- Guild Materials
		(item.ObjSubType == 0 or item.ObjSubType == 1 or item.ObjSubType == 2) then -- SubType Ore, Herbs or Wood
		return (item.ItemShopItem and (Guild_Materials == "isbag"))
	elseif item.Id == 207325 or item.Id == 207329 or item.Id == 207929 then -- Guild stones, rubies and runes
		return Guild_Other == "isbag"
	end
end

function processrewards()
	if Transform_Pots_To_IS_Bag == true or Backpack_Ticket_To_IS_Bag == true or (Guild_Materials == "isbag") or (Guild_Other == "isbag") then
		inventory:update()
		local item
		for i = 61,240 do
			item = inventory.BagSlot[i]
			if (not item.Empty) and item.Available and isbageval(item) then
				cprintf(cli.yellow,"Placing '%s' in the itemshop backpack.\n",item.Name)
				item:moveTo("itemshop")
			end
		end
	end

	if Guild_Materials == "donate" then
		GuildDonate("all",8)
	end

	if Guild_Other == "donate" then
		GuildDonate("rubies")
		GuildDonate("stones")
		GuildDonate("runes")
	end

	if Use_XP_TP_Rewards == true then
		repeat
			yrest(500)
		until inventory:useItem(piepackage) == false
		yrest(1500)
		inventory:update()
		for i = 61,240 do
			item = inventory.BagSlot[i]
			if (not item.Empty) and item.Available then
				if (item.Id >= 240743 and item.Id <= 240746) or -- Pumpkin Pie
					 item.Id == 240742 then 					 -- Pumpkin Rice
					cprintf(cli.yellow,"Eating '%s'.\n",item.Name)
					local cd, success
					repeat
						yrest(50)
						cd, success = item:getRemainingCooldown()
					until success == false and cd == 0
					item:use()
				end
			end
		end
	end
end

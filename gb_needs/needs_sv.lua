require "resources/essentialmode/lib/MySQL"
MySQL:open("127.0.0.1", "gta5_gamemode_essential", "root", "monpasse")
-- PARAMS
local malusfood = 10
local bonusfood = 100
local maluswater = 20
local bonuswater = 100
local malusneeds = 100
local bonusneeds = 10
local timingsave = 600000
-- CHECK NEEDS
function checkneeds(player)
  local executed_query = MySQL:executeQuery("SELECT * FROM users WHERE identifier = '@name'", {['@name'] = player})
  local result = MySQL:getResults(executed_query, {'food', 'water', 'needs'}, "identifier")
  return tonumber(result[1].food),tonumber(result[1].water),tonumber(result[1].needs)
end
-- UPDATE NEEDS
function updateneeds(player, calories, waterdrops, wc)
  local food, water, needs = table.unpack{checkneeds(player)}
  local new_food = food - calories
  local new_water = water - waterdrops
  local new_needs = needs + wc
  MySQL:executeQuery("UPDATE users SET `food`='@foodvalue', `water`='@watervalue', `needs`='@needsvalue' WHERE identifier = '@identifier'", {['@foodvalue'] = new_food, ['@watervalue'] = new_water, ['@needsvalue'] = new_needs, ['@identifier'] = player})
end
-- SET NEEDS
function setneeds(player, food, water, needs)
  MySQL:executeQuery("UPDATE users SET `food`='@foodvalue', `water`='@watervalue', `needs`='@needsvalue' WHERE identifier = '@identifier'", {['@foodvalue'] = food, ['@watervalue'] = water, ['@needsvalue'] = needs, ['@identifier'] = player})
end
-- FOOD
function addcalories(player, calories)
  local food, water, needs = table.unpack{checkneeds(player)}
  local new_food = food + calories
  if(tonumber(new_food) >= tonumber(bonusfood)) then
	new_food = bonusfood
  end
  MySQL:executeQuery("UPDATE users SET `food`='@value' WHERE identifier = '@identifier'", {['@value'] = new_food, ['@identifier'] = player})
end

function removecalories(player, calories)
  local food, water, needs = table.unpack{checkneeds(player)}
  local new_food = food - calories
  MySQL:executeQuery("UPDATE users SET `food`='@value' WHERE identifier = '@identifier'", {['@value'] = new_food, ['@identifier'] = player})
end

RegisterServerEvent('gabs:removecalories')
AddEventHandler('gabs:removecalories', function(source, calories)
  TriggerEvent('es:getPlayerFromId', source, function(user)
      local player = user.identifier
      local food, water, needs = table.unpack{checkneeds(player)}
      if(tonumber(food) > 1) then
        removecalories(player, calories)
        local new_food, new_water, new_needs = table.unpack{checkneeds(player)}
        TriggerClientEvent("gabs:setfood", source, new_food)
--        TriggerClientEvent("gabs:remove_calories", source, calories)
        CancelEvent()
		if(tonumber(new_food) <= 0) then
			TriggerClientEvent('es_admin:kill', source)
			setneeds(player, tonumber(bonusfood), tonumber(bonuswater), 0)
			TriggerClientEvent("gabs:setfood", source, tonumber(bonusfood))
			TriggerClientEvent("gabs:setwater", source, tonumber(bonuswater))
			TriggerClientEvent("gabs:setneeds", source, 0)
			CancelEvent()
		end
      else
        TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Mort de faim")
        CancelEvent()
      end
  end)
end)

RegisterServerEvent('gabs:addcalories')
AddEventHandler('gabs:addcalories', function(source, calories)
  TriggerEvent('es:getPlayerFromId', source, function(user)
      local player = user.identifier
      local food, water, needs = table.unpack{checkneeds(player)}
      if(tonumber(food) < tonumber(bonusfood)) then
        addcalories(player, calories)
        local new_food, new_water, new_needs = table.unpack{checkneeds(player)}
        TriggerClientEvent("gabs:setfood", source, new_food)
--        TriggerClientEvent("gabs:add_calories", source, calories)
--		TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Miam")
		TriggerClientEvent("gabs:eat", source)
        CancelEvent()
		if(tonumber(new_food) <= 0) then
			TriggerClientEvent('es_admin:kill', source)
			setneeds(player, tonumber(bonusfood), tonumber(bonuswater), 0)
			TriggerClientEvent("gabs:setfood", source, tonumber(bonusfood))
			TriggerClientEvent("gabs:setwater", source, tonumber(bonuswater))
			TriggerClientEvent("gabs:setneeds", source, 0)
			CancelEvent()
		end
      else
        TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Pas faim")
        CancelEvent()
      end
  end)
end)

TriggerEvent('es:addCommand', 'manger', function(source, args, user)
	if(tonumber(args[2])) then
		local calories = tonumber(args[2])
		TriggerEvent('gabs:addcalories', source, calories)
	else
		TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Exemple : /manger 50")
	end
end)
-- WATER
function addwater(player, waterdrops)
  local food, water, needs = table.unpack{checkneeds(player)}
  local new_water = water + waterdrops
  if(tonumber(new_water) >= tonumber(bonuswater)) then
	new_water = bonuswater
  end
  MySQL:executeQuery("UPDATE users SET `water`='@value' WHERE identifier = '@identifier'", {['@value'] = new_water, ['@identifier'] = player})
end

function removewater(player, waterdrops)
  local food, water, needs = table.unpack{checkneeds(player)}
  local new_water = water - waterdrops
  MySQL:executeQuery("UPDATE users SET `water`='@value' WHERE identifier = '@identifier'", {['@value'] = new_water, ['@identifier'] = player})
end

RegisterServerEvent('gabs:removewater')
AddEventHandler('gabs:removewater', function(source, waterdrops)
  TriggerEvent('es:getPlayerFromId', source, function(user)
      local player = user.identifier
      local food, water, needs = table.unpack{checkneeds(player)}
      if(tonumber(maluswater) <= tonumber(water)) then
        removewater(player, waterdrops)
        local new_food, new_water, new_needs = table.unpack{checkneeds(player)}
        TriggerClientEvent("gabs:setwater", source, new_water)
--        TriggerClientEvent("gabs:remove_water", source, waterdrops)
        CancelEvent()
		if(tonumber(new_water) <= 0) then
			TriggerClientEvent('es_admin:kill', source)
			setneeds(player, tonumber(bonusfood), tonumber(bonuswater), 0)
			TriggerClientEvent("gabs:setfood", source, tonumber(bonusfood))
			TriggerClientEvent("gabs:setwater", source, tonumber(bonuswater))
			TriggerClientEvent("gabs:setneeds", source, 0)
			CancelEvent()
		end
      else
        TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Mort de soif")
        CancelEvent()
      end
  end)
end)

RegisterServerEvent('gabs:addwater')
AddEventHandler('gabs:addwater', function(source, waterdrops)
  TriggerEvent('es:getPlayerFromId', source, function(user)
      local player = user.identifier
      local food, water, needs = table.unpack{checkneeds(player)}
      if(tonumber(water) <= tonumber(bonuswater)) then
        addwater(player, waterdrops)
        local new_food, new_water, new_needs = table.unpack{checkneeds(player)}
        TriggerClientEvent("gabs:setwater", source, new_water)
--        TriggerClientEvent("gabs:add_water", source, waterdrops)
--		TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Vous avez bu")
		TriggerClientEvent("gabs:drink", source)
        CancelEvent()
		if(tonumber(new_water) <= 0) then
			TriggerClientEvent('es_admin:kill', source)
			setneeds(player, tonumber(bonusfood), tonumber(bonuswater), 0)
			TriggerClientEvent("gabs:setfood", source, tonumber(bonusfood))
			TriggerClientEvent("gabs:setwater", source, tonumber(bonuswater))
			TriggerClientEvent("gabs:setneeds", source, 0)
			CancelEvent()
		end
      else
        TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Vous n'avez pas soif")
        CancelEvent()
      end
  end)
end)

TriggerEvent('es:addCommand', 'boire', function(source, args, user)
	if(tonumber(args[2])) then
		local waterdrops = tonumber(args[2])
		TriggerEvent('gabs:addwater', source, waterdrops)
	else
		TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Exemple : /boire 50")
	end
end)
-- NEEDS
function addneeds(player, wc)
  local food, water, needs = table.unpack{checkneeds(player)}
  local new_needs = needs + wc
  MySQL:executeQuery("UPDATE users SET `needs`='@value' WHERE identifier = '@identifier'", {['@value'] = new_needs, ['@identifier'] = player})
end

function removeneeds(player, wc)
  local food, water, needs = table.unpack{checkneeds(player)}
  local new_needs = needs - wc
  if(tonumber(new_needs) <= 0) then
	new_needs = 0
  end
  MySQL:executeQuery("UPDATE users SET `needs`='@value' WHERE identifier = '@identifier'", {['@value'] = new_needs, ['@identifier'] = player})
end

RegisterServerEvent('gabs:removeneeds')
AddEventHandler('gabs:removeneeds', function(source, wc)
  TriggerEvent('es:getPlayerFromId', source, function(user)
      local player = user.identifier
      local food, water, needs = table.unpack{checkneeds(player)}
      if(tonumber(needs) >= 1) then
        removeneeds(player, wc)
        local new_food, new_water, new_needs = table.unpack{checkneeds(player)}
        TriggerClientEvent("gabs:setneeds", source, new_needs)
--        TriggerClientEvent("gabs:remove_needs", source, wc)
--		TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Pipi caca")
		TriggerClientEvent("gabs:pee", source)
        CancelEvent()
		if(tonumber(new_needs) >= tonumber(malusneeds)) then
			TriggerClientEvent('es_admin:kill', source)
			setneeds(player, tonumber(bonusfood), tonumber(bonuswater), 0)
			TriggerClientEvent("gabs:setfood", source, tonumber(bonusfood))
			TriggerClientEvent("gabs:setwater", source, tonumber(bonuswater))
			TriggerClientEvent("gabs:setneeds", source, 0)
			CancelEvent()
		end
      else
        TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Vous n'avez aucun besoin")
        CancelEvent()
      end
  end)
end)

RegisterServerEvent('gabs:addneeds')
AddEventHandler('gabs:addneeds', function(source, wc)
  TriggerEvent('es:getPlayerFromId', source, function(user)
      local player = user.identifier
      local food, water, needs = table.unpack{checkneeds(player)}
      if(tonumber(needs) <= tonumber(malusneeds)) then
        addneeds(player, wc)
        local new_food, new_water, new_needs = table.unpack{checkneeds(player)}
        TriggerClientEvent("gabs:setneeds", source, new_needs)
--        TriggerClientEvent("gabs:add_needs", source, wc)
        CancelEvent()
		if(tonumber(new_needs) >= tonumber(malusneeds)) then
			TriggerClientEvent('es_admin:kill', source)
			setneeds(player, tonumber(bonusfood), tonumber(bonuswater), 0)
			TriggerClientEvent("gabs:setfood", source, tonumber(bonusfood))
			TriggerClientEvent("gabs:setwater", source, tonumber(bonuswater))
			TriggerClientEvent("gabs:setneeds", source, 0)
			CancelEvent()
		end
      else
--        TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Mort")
		TriggerClientEvent('es_admin:kill', source)
		setneeds(player, tonumber(bonusfood), tonumber(bonuswater), 0)
		TriggerClientEvent("gabs:setfood", source, tonumber(bonusfood))
		TriggerClientEvent("gabs:setwater", source, tonumber(bonuswater))
		TriggerClientEvent("gabs:setneeds", source, 0)
        CancelEvent()
      end
  end)
end)

TriggerEvent('es:addCommand', 'pipi', function(source, args, user)
	if(tonumber(args[2])) then
		local wc = tonumber(args[2])
		TriggerEvent('gabs:removeneeds', source, wc)
	else
		TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Exemple : /pipi 50")
	end
end)
-- START NEEDS
AddEventHandler('es:playerLoaded', function(source)
  TriggerEvent('es:getPlayerFromId', source, function(user)
      local player = user.identifier
      local food, water, needs = table.unpack{checkneeds(player)}
      TriggerClientEvent("gabs:setfood", source, food)
	  TriggerClientEvent("gabs:setwater", source, water)
	  TriggerClientEvent("gabs:setneeds", source, needs)
    end)
end)

local function saveneeds()
	SetTimeout(timingsave, function()
		TriggerEvent("es:getPlayers", function(users)
			for k,v in pairs(users)do
				local player = v.identifier
				local food, water, needs = table.unpack{checkneeds(player)}
				if(tonumber(food) >= 1) and (tonumber(water) >= 1) and (tonumber(needs) < tonumber(malusneeds)) then
					updateneeds(player, malusfood, maluswater, bonusneeds)
					local new_food, new_water, new_needs = table.unpack{checkneeds(player)}
					TriggerClientEvent("gabs:setfood", source, new_food)
--					TriggerClientEvent("gabs:remove_calories", source, malusfood)
					TriggerClientEvent("gabs:setwater", source, new_water)
--					TriggerClientEvent("gabs:remove_water", source, maluswater)
					TriggerClientEvent("gabs:setneeds", source, new_needs)
--					TriggerClientEvent("gabs:add_needs", source, bonusneeds)
					CancelEvent()
					if(tonumber(new_food) <= 0) or (tonumber(new_water) <= 0) or (tonumber(new_needs) >= tonumber(malusneeds)) then
						TriggerClientEvent('es_admin:kill', source)
						setneeds(player, tonumber(bonusfood), tonumber(bonuswater), 0)
						TriggerClientEvent("gabs:setfood", source, tonumber(bonusfood))
						TriggerClientEvent("gabs:setwater", source, tonumber(bonuswater))
						TriggerClientEvent("gabs:setneeds", source, 0)
						CancelEvent()
					end
				else
					TriggerClientEvent('es_admin:kill', source)
					setneeds(player, tonumber(bonusfood), tonumber(bonuswater), 0)
					TriggerClientEvent("gabs:setfood", source, tonumber(bonusfood))
					TriggerClientEvent("gabs:setwater", source, tonumber(bonuswater))
					TriggerClientEvent("gabs:setneeds", source, 0)
--					TriggerClientEvent('chatMessage', source, "", {0, 0, 200}, "Mort")
					CancelEvent()
				end
			end
		end)

		saveneeds()
	end)
end

saveneeds()
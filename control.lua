-- ON ENTITY DIED
script.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity
	local train = entity.train
	-- stops the train
    train.speed = 0
	-- creates ghost entity
    local ghost_entity = game.surfaces[entity.surface.name].create_entity{
        name = "entity-ghost",
        inner_name = entity.name,
        position = entity.position,
		direction = entity.direction,
        force = entity.force,
        create_build_effect_smoke = false,
    }
	-- checks if destroyed entity had any special properties
	local fuel_inv = entity.get_fuel_inventory()
	local wagon_inv = entity.get_inventory(defines.inventory.cargo_wagon)
	local request_proxies = game.surfaces[entity.surface.name].find_entities_filtered{type = "item-request-proxy", name = "item-request-proxy", position = entity.position}
	local found_proxies = false
	for _, proxy in pairs(request_proxies) do
		if proxy.proxy_target == entity then
			found_proxies = true
			break
		end
	end
	if train.manual_mode == false or (entity.grid and entity.grid.equipment[1]) or (fuel_inv and fuel_inv.is_empty() == false) or (wagon_inv.is_filtered() or (wagon_inv.supports_bar() and (wagon_inv.get_bar() <= #wagon_inv))) or found_proxies then
		-- registers the ghost entity
		local registration_number = script.register_on_entity_destroyed(ghost_entity)
		-- saves type, name and position
		if global.ick_destroyed_train == nil then
			global.ick_destroyed_train = {}
		end
		global.ick_destroyed_train[registration_number] = {type = entity.type, name = entity.name, position = entity.position}
		-- saves number of carriages per type if train is in automatic mode
		if train.manual_mode == false then
			local carriages = {["locomotive"] = 0, ["cargo-wagon"] = 0, ["fluid-wagon"] = 0, ["artillery-wagon"] = 0}
			for _, entity in pairs(train.carriages) do
				carriages[entity.type] = carriages[entity.type] + 1
			end
			global.ick_destroyed_train[registration_number].train = carriages
		end
		-- adds request for fuel
		local requests = {}
		if settings.global["ick-include-fuel"].value then
			if game.item_prototypes[settings.global["ick-fuel-type"].value] then
				requests = {[settings.global["ick-fuel-type"].value] = settings.global["ick-fuel-amount"].value}
			elseif fuel_inv and fuel_inv.is_empty() == false then
				requests = fuel_inv.get_contents()
			end
		end
		-- adds request for equipment
		if settings.global["ick-include-equipment"].value and entity.grid and entity.grid.equipment[1] then
			for name, count in pairs(entity.grid.get_contents()) do
				if requests[name] then
					requests[name] = requests[name] + count
				else
					requests[name] = count
				end
			end
			-- save equipment if entity is a cargo wagon
			if entity.type == "cargo-wagon" then
				global.ick_destroyed_train[registration_number].equipment = entity.grid.get_contents()
			end
		end
		-- adds request for item-request-proxies
		if found_proxies then
			for _, proxy in pairs(request_proxies) do
				if proxy.proxy_target == entity then
					for name, count in pairs(proxy.item_requests) do
						if requests[name] then
							requests[name] = requests[name] + count
						else
							requests[name] = count
						end
					end
				end
			end
		end
		ghost_entity.item_requests = requests
		-- saves inventory filters
		if wagon_inv.is_filtered() then
			local filters = {}
			for i = 1, #wagon_inv do
				table.insert(filters, i, wagon_inv.get_filter(i))
			end
			global.ick_destroyed_train[registration_number].filters = filters
		end
		-- saves inventory limit
		if wagon_inv.supports_bar() and (wagon_inv.get_bar() <= #wagon_inv) then
			global.ick_destroyed_train[registration_number].bar = wagon_inv.get_bar()
		end
	end
end, {{filter = "rolling-stock"}})


-- ON ENTITY BUILT
local function built_entity(entity)
	if global.ick_destroyed_train then
		for i, stored_info in pairs(global.ick_destroyed_train) do
			if stored_info.type == entity.type and stored_info.name == entity.name and stored_info.position.x == entity.position.x and stored_info.position.y == entity.position.y then
				-- Find and register the created item request proxy
				local request_proxy = game.surfaces[entity.surface.name].find_entity("item-request-proxy", entity.position)
				if stored_info.equipment and request_proxy then
					local registration_number = script.register_on_entity_destroyed(request_proxy)
					global.ick_destroyed_train[registration_number] = {position = entity.position, requests = stored_info.equipment, target = entity}
				end
				-- sets inventory filters
				if stored_info.filters then
					for i = 1, #entity.get_inventory(defines.inventory.cargo_wagon) do
						entity.get_inventory(defines.inventory.cargo_wagon).set_filter(i, stored_info.filters[i])
					end
				end
				-- sets inventory limit
				if stored_info.bar then
					entity.get_inventory(defines.inventory.cargo_wagon).set_bar(stored_info.bar)
				end
				-- sets train to automatic mode again, when train is restored completely
				local old_train = stored_info.train
				if settings.global["ick-automatic-mode"].value and old_train then
					local new_train = {["locomotive"] = 0, ["cargo-wagon"] = 0, ["fluid-wagon"] = 0, ["artillery-wagon"] = 0}
					for _, entity in pairs(entity.train.carriages) do
						new_train[entity.type] = new_train[entity.type] + 1
					end
					if old_train["locomotive"] == new_train["locomotive"] and old_train["cargo-wagon"] == new_train["cargo-wagon"] and old_train["fluid-wagon"] == new_train["fluid-wagon"] and old_train["artillery-wagon"] == new_train["artillery-wagon"] then
						entity.train.manual_mode = false
					end
				end
			end
		end
	end
end

-- called when a player builds the ghost entity
script.on_event(defines.events.on_built_entity, function(event)
    built_entity(event.created_entity)
end, {{filter = "rolling-stock"}})

-- called when a robot builds the ghost entity
script.on_event(defines.events.on_robot_built_entity, function(event)
    built_entity(event.created_entity)
end, {{filter = "rolling-stock"}})


-- ON ENTITY DESTROYED
-- called when a registerd entity gets removed (rolling stock ghosts or item request proxies)
script.on_event(defines.events.on_entity_destroyed, function(event)
	if global.ick_destroyed_train and global.ick_destroyed_train[event.registration_number] then
		-- moves equipment from cargo inventory into grid
		local registerd_entity = global.ick_destroyed_train[event.registration_number]
		if registerd_entity.requests and registerd_entity.target then
			local inventory = registerd_entity.target.get_inventory(defines.inventory.cargo_wagon)
			local grid = registerd_entity.target.grid
			for name, count in pairs(registerd_entity.requests) do
				if inventory and grid then
					for i = 1, count do
						local stack = inventory.find_item_stack(name)
						if stack and grid.put{name = name} then
							stack.count = stack.count - 1
						end
					end
				end
			end
		end
		-- deletes saved inventory properties
		global.ick_destroyed_train[event.registration_number] = nil
	end
end)

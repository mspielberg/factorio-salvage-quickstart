local crashfx = require "crashfx"

local function moveposition(position, offset)
  return {x=position.x + offset.x, y=position.y + offset.y}
end

local function offset(direction, longitudinal, orthogonal)
  if direction == defines.direction.north then
    return {x=orthogonal, y=-longitudinal}
  end

  if direction == defines.direction.south then
    return {x=-orthogonal, y=longitudinal}
  end

  if direction == defines.direction.east then
    return {x=longitudinal, y=orthogonal}
  end

  if direction == defines.direction.west then
    return {x=-longitudinal, y=-orthogonal}
  end
end

local function on_built_entity(event)
  local entity = event.created_entity or event.entity
  local chest_name
  local off
  if entity.name == "sqs-mining-drill" then
    entity.direction = defines.direction.south
    local chest = entity.surface.create_entity{
      name = "sqs-mining-drill-chest",
      force = entity.force,
      position = moveposition(entity.position, { x = 0.5, y = 0.5 }),
    }
  elseif entity.name == "sqs-roboport" then
    local chest = entity.surface.create_entity{
      name = "logistic-chest-storage",
      force = entity.force,
      position = moveposition(entity.position, { x = 0.5, y = 0.5 }),
    }
    chest.destructible = false
    chest.minable = false
  end
end

local function on_mined_entity(event)
  local entity = event.entity
  if entity.name == "sqs-mining-drill-chest" then
    local drill = entity.surface.find_entity(
      "sqs-mining-drill",
      moveposition(entity.position, {x = -0.5, y = -0.5}))
    if drill then drill.destroy() end
  elseif entity.name == "sqs-roboport" then
    local chest = entity.surface.find_entity(
      "logistic-container-storage",
      moveposition(entity.position, {x = 0.5, y = 0.5}))
    local buffer = event.buffer
    if chest then
      if buffer then
        local inventory = chest.get_inventory(defines.inventory.chest)
        for i=1,#inventory do
          local stack = inventory[i]
          if stack.valid_for_read then
            buffer.insert(stack)
            stack.clear()
          end
        end
      end
      chest.destroy()
    end
  end
end

local CRASH_ITEMS = {
  {"sqs-mining-drill"},
  {"sqs-furnace"},
  {"sqs-roboport", "sqs-construction-robot"},
}

local function on_tick(event)
  if event.tick == 0 then
    if game.is_multiplayer() then
      player.print({"sgs-intro-msg"})
    else
      game.show_message_dialog{text = {"sqs-intro-msg"}}
    end
  end

  local container = crashfx.run(event.tick)
  if container then
    local item_names = CRASH_ITEMS[global.crashfx.containers_spawned]
    for _, item_name in pairs(item_names) do
      container.insert(item_name)
    end
  elseif container == false then
    log("crash sequence ended on tick "..event.tick)
    script.on_event(defines.events.on_tick, nil)
  end
end

local handlers = {
  on_built_entity = on_built_entity,
  on_player_mined_entity = on_mined_entity,
  on_robot_built_entity = on_built_entity,
  on_robot_mined_entity = on_mined_entity,
  script_raised_destroy = on_mined_entity,
  script_raised_revive = on_built_entity,
}

for name, handler in pairs(handlers) do
  script.on_event(defines.events[name], handler)
end

local function on_load()
  if not (global.crashfx and global.crashfx.done) then
    script.on_event(defines.events.on_tick, on_tick)
  end
end

local function on_init()
  if remote.interfaces["freeplay"] then
    remote.call("freeplay", "set_skip_intro", true)
    local starting = remote.call("freeplay", "get_created_items")
    starting["burner-mining-drill"] = nil
    starting["stone-furnace"] = nil
    remote.call("freeplay", "set_created_items", starting)
  end
  on_load()
end

script.on_init(on_init)
script.on_load(on_load)

script.on_configuration_changed(function(data)
  if data.mod_changes
  and data.mod_changes[script.mod_name]
  and data.mod_changes[script.mod_name].old_version == "0.1.0" then
    global.crashfx = { containers_spawned = 3 }
    for _, s in pairs(game.surfaces) do
      for _, chest in pairs(s.find_entities_filtered{name = "sqs-mining-drill-chest"}) do
        chest.minable = true
        chest.teleport(moveposition(chest.position, { x = 1, y = 1 }))
      end
    end
  end
end)


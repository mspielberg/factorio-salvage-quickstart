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

local function on_init()
  if remote.interfaces["freeplay"] then
    remote.call("freeplay", "set_created_items",
      {
        ["pistol"] = 1,
        ["firearm-magazine"] = 10,
        ["sqs-furnace"] = 1,
        ["sqs-roboport"] = 1,
        ["sqs-construction-robot"] = 10,
        ["sqs-core-sampling-drill"] = 1,
      })
  end
end

local function on_built_entity(event)
  local entity = event.created_entity or event.entity
  local chest_name
  local offset
  if entity.name == "sqs-core-sampling-drill" then
    chest_name = "sqs-core-sampling-drill-chest"
    offset = { x = -0.5, y = -0.5 }
  elseif entity.name == "sqs-roboport" then
    chest_name ="logistic-chest-storage"
    offset = { x =  0.5, y =  0.5 }
  else
    return
  end
  local chest = entity.surface.create_entity{
    name = chest_name,
    force = entity.force,
    position = moveposition(entity.position, offset),
  }
  chest.destructible = false
  chest.minable = false
end

local function on_mined_entity(event)
  local entity = event.entity
  if entity.name == "sqs-core-sampling-drill" or entity.name == "sqs-roboport" then
    local chest = entity.surface.find_entities_filtered{
      type = {"container", "logistic-container"},
      area = entity.bounding_box,
    }[1]
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

local handlers = {
  on_built_entity = on_built_entity,
  on_player_mined_entity = on_mined_entity,
  on_robot_built_entity = on_built_entity,
  on_robot_mined_entity = on_mined_entity,
  script_raised_destroy = on_mined_entity,
  script_raised_revive = on_built_entity,
}

script.on_init(on_init)
for name, handler in pairs(handlers) do
  script.on_event(defines.events[name], handler)
end

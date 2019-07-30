local function foreach_sprite(t, f)
  if t.filename and t.filename:find("%.png$") then
    f(t)
  end
  for k, v in pairs(t) do
    if type(v) == "table" then
      foreach_sprite(v, f)
    end
  end
end

local function add_tint(t, tint)
  foreach_sprite(t, function(s)
    s.tint = tint
  end)
end

local function change_scale(t, factor)
  foreach_sprite(t, function(s)
    s.scale = (s.scale or 1) * factor
    if s.shift then
      s.shift = util.mul_shift(s.shift, factor)
    end
  end)
end

local drill_chest = table.deepcopy(data.raw.container["steel-chest"])
drill_chest.name = "sqs-mining-drill-chest"
drill_chest.order = "sqs-mining-drill-chest"
drill_chest.minable.result = "sqs-mining-drill"
drill_chest.placeable_by = {item = "sqs-mining-drill", count = 1}
drill_chest.collision_box = {{-0.3, -0.3}, {0.3, 0.3}}
drill_chest.selection_box = {{-1.3, -1.3}, {0.5, 0.5}}
drill_chest.selection_priority = 60
drill_chest.fast_replaceable_group = nil
drill_chest.inventory_size = 2

local drill = table.deepcopy(data.raw["mining-drill"]["burner-mining-drill"])
drill.name = "sqs-mining-drill"
drill.icon = "__salvage-quickstart__/graphics/icons/sqs-mining-drill.png"
table.insert(drill.flags, "not-rotatable")
drill.minable = nil
drill.energy_source = { type = "void" }
drill.mining_speed = 10
drill.vector_to_place_result = {0.5, 0.5}
drill.working_sound.sound.filename = "__base__/sound/fast-transport-belt.ogg"
drill.animations.north = drill.animations.south
add_tint(drill, {r=1, g=0.8, b=0.8})

local furnace = table.deepcopy(data.raw["furnace"]["electric-furnace"])
furnace.name = "sqs-furnace"
furnace.icon = "__salvage-quickstart__/graphics/icons/sqs-furnace.png"
furnace.type = "assembling-machine"
furnace.minable.result = "sqs-furnace"
furnace.corpse = "medium-small-remnants"
furnace.energy_source = { type = "void" }
furnace.collision_box = {{-0.8, -0.8}, {0.8, 0.8}}
furnace.selection_box = {{-1, -1}, {1, 1}}
furnace.crafting_speed = 20
for _, vis in pairs(furnace.working_visualisations) do
  vis.animation.animation_speed = 0.06
  vis.animation.hr_version.animation_speed = 0.06
end
furnace.working_sound.sound.filename = "__base__/sound/accumulator-idle.ogg"
change_scale(furnace, 2/3)
add_tint(furnace, {r=1, g=0.8, b=0.8})

local roboport = table.deepcopy(data.raw["roboport"]["roboport"])
roboport.name = "sqs-roboport"
roboport.icon = "__salvage-quickstart__/graphics/icons/sqs-roboport.png"
roboport.minable.result = "sqs-roboport"
roboport.corpse = "medium-small-remnants"
roboport.energy_source = { type = "void" }
roboport.recharge_minimum = "0J"
roboport.collision_box = {{-0.8, -0.8}, {0.8, 0.8}}
roboport.selection_box = {{-1, -1}, {1, 1}}
roboport.energy_usage = "500kW"
roboport.charging_energy = "250kW"
roboport.logistics_radius = 1
roboport.charge_approach_distance = 3
roboport.robot_slots_count = 1
roboport.material_slots_count = 1
roboport.charging_offsets = {{-1, 0}, {1, 0}}
change_scale(roboport, 0.5)
add_tint(roboport, {r=0.8, g=0.8, b=1})

local bot = table.deepcopy(data.raw["construction-robot"]["construction-robot"])
bot.name = "sqs-construction-robot"
bot.icon = "__salvage-quickstart__/graphics/icons/sqs-construction-robot.png"
bot.minable.result = "sqs-construction-robot"
bot.max_health = 500
bot.max_payload_size = 3
bot.speed = 0.20
bot.max_energy = "300kJ"
bot.energy_per_tick = "10J"
bot.energy_per_move = "500J"
change_scale(bot, 0.75)
add_tint(bot, {r=0.8, g=0.8, b=1})

data:extend{drill_chest, drill, furnace, roboport, bot}

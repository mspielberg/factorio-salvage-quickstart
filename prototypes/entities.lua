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

local drill_chest =
{
  type = "container",
  name = "sqs-mining-drill-chest",
  icon = "__base__/graphics/icons/steel-chest.png",
  icon_size = 32,
  flags = {"placeable-neutral", "player-creation"},
  order = "sqs-mining-drill-chest",
  minable = {mining_time = 0.2, result = "sqs-mining-drill"},
  max_health = 50,
  corpse = "small-remnants",
  open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
  close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
  resistances =
  {
    {
      type = "fire",
      percent = 90
    },
    {
      type = "impact",
      percent = 60
    }
  },
  collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
  selection_box = {{-1.5, -1.5}, {0.5, 0.5}},
  fast_replaceable_group = "container",
  inventory_size = 2,
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  picture =
  {
    layers =
    {
      {
        filename = "__base__/graphics/entity/steel-chest/steel-chest.png",
        priority = "extra-high",
        width = 32,
        height = 40,
        shift = util.by_pixel(0, -0.5),
        hr_version =
        {
          filename = "__base__/graphics/entity/steel-chest/hr-steel-chest.png",
          priority = "extra-high",
          width = 64,
          height = 80,
          shift = util.by_pixel(-0.25, -0.5),
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/steel-chest/steel-chest-shadow.png",
        priority = "extra-high",
        width = 56,
        height = 22,
        shift = util.by_pixel(12, 7.5),
        draw_as_shadow = true,
        hr_version =
        {
          filename = "__base__/graphics/entity/steel-chest/hr-steel-chest-shadow.png",
          priority = "extra-high",
          width = 110,
          height = 46,
          shift = util.by_pixel(12.25, 8),
          draw_as_shadow = true,
          scale = 0.5
        }
      }
    }
  },
}

local drill = table.deepcopy(data.raw["mining-drill"]["burner-mining-drill"])
drill.name = "sqs-mining-drill"
drill.icon = "__salvage-quickstart__/graphics/icons/sqs-mining-drill.png"
table.insert(drill.flags, "not-rotatable")
drill.selection_box = nil
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

require "util"

local wreckages = {
  { name = "medium-ship-wreck", minable = { mining_time = 2, results = {
    { type = "item", name = "copper-cable", probability = .80, amount_min = 1, amount_max = 10 },
    { type = "item", name = "steel-plate", probability = .60, amount_min = 1, amount_max = 4 },
  }}},
  { name = "small-ship-wreck", minable = { mining_time = 1, results = {
    { type = "item", name = "steel-plate", probability = .20, amount_min = 1, amount_max = 2 },
  }}},
  { name = "small-scorchmark", results = nil },
}

local function add_resistance(proto, type, decrease, percent)
  if not proto.resistances then proto.resistances = {} end
  for _, resist in pairs(proto.resistances) do
    if resist.type == type then
      resist.decrease = (resist.decrease or 0) < decrease and decrease or resist.decrease
      resist.percent = (resist.percent or 0) < percent and percent or resist.percent
      return
    end
  end
  table.insert(proto.resistances, { type = type, decrease = decrease, percent = percent })
end

local function add_resistances(proto)
  add_resistance(proto, "physical", 10, 90)
  add_resistance(proto, "fire", 0, 100)
  proto.max_health = (proto.max_health < 250) and 250 or proto.max_health
end

local types = { "container", "simple-entity", "corpse" }
local function get_wreck(name)
  for _, type in pairs(types) do
    local proto = data.raw[type][name]
    if proto then return proto end
  end
end

for _, wreck_info in pairs(wreckages) do
  local name = wreck_info.name
  local sqs_wreck = util.merge{get_wreck(name), wreck_info}
  sqs_wreck.name = "sqs-"..sqs_wreck.name
  data:extend{sqs_wreck}
end

add_resistances(data.raw.container["big-ship-wreck-1"])
add_resistances(data.raw.container["big-ship-wreck-2"])
add_resistances(data.raw.container["big-ship-wreck-3"])

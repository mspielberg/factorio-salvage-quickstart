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

local function add_resistances(proto)
  if not proto.resistances then proto.resistances = {} end
  local found_phys, found_fire
  for _, resist in pairs(proto.resistances) do
    if resist.type == "physical" then
      resist.decrease = (resist.decrease or 0) < 10 and 10 or resist.decrease
      resist.percent = (resist.percent or 0) < 0.9 and 0.9 or resist.percent
      found_phys = true
    end
    if resist.type == "fire" then
      resist.percent = (resist.percent or 0) < 1 and 1 or resist.percent
      found_fire = true
    end
  end

  if not found_phys then
    table.insert(proto.resistances, { type = "physical", decrease = 10, percent = .9 })
  end
  if not found_fire then
    table.insert(proto.resistances, { type = "fire", decrease = 0, percent = 1 })
  end

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
  sqs_wreck = util.merge{get_wreck(name), wreck_info}
  sqs_wreck.name = "sqs-"..sqs_wreck.name
  data:extend{sqs_wreck}
end

add_resistances(data.raw.container["big-ship-wreck-1"])
add_resistances(data.raw.container["big-ship-wreck-2"])
add_resistances(data.raw.container["big-ship-wreck-3"])
log(serpent.block(data.raw.container["big-ship-wreck-1"]))

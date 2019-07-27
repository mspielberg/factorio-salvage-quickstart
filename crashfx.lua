local END_TIME = 30 * 60
local DECAY = 300
local CENTER_STDDEV = 15
local NUM_CONTAINERS = 3
local CONTAINER_PROB = 0.01
local CONTAINER_STDDEV = 10
local FIRE_PROB = 0.7
local SAFE_RANGE = 4
local WRECKAGE_FORCE = "neutral"

local WRECKS = {
  { prob = 0.1, name = "sqs-medium-ship-wreck", explosion = "ground-explosion", stddev = 20 },
  { prob = 0.5, name = "sqs-small-ship-wreck" , explosion = "big-explosion"   , stddev = 50 },
  { prob = 3 , name = "sqs-small-scorchmark" , explosion = "explosion"       , stddev = 200 },
}

local ln = math.log
local random = math.random

local center
local nauvis

-- returns a point sampled from a normal distribution centered at 0,0
-- with the provided standard deviation, by the https://en.wikipedia.org/wiki/Marsaglia_polar_method
local function gaussian_point(stddev)
  local x, y = random() * 2 - 1, random() * 2 - 1
  local s = x * x + y * y
  if s >= 1 then return gaussian_point(stddev) end
  local scale = (-2 * ln(s) / s) ^ 0.5 * stddev
  return { x = x * scale, y = y * scale }
end

local function random_position(stddev)
  center = global.crashfx.center
  if not center then
    center = gaussian_point(CENTER_STDDEV)
    global.crashfx.center = center
  end

  local offset = gaussian_point(stddev)
  return { x = center.x + offset.x, y = center.y + offset.y }
end

local AVOID_CHARACTERS = {"character", "container"}
local AVOID_RESOURCES = {"character", "container", "resource"}
local avoid_types_cache = {}
local function avoid_types(name)
  local to_avoid = avoid_types_cache[name]
  if not to_avoid then
    local proto = game.entity_prototypes[name]
    if proto.type == "container" then
      to_avoid = AVOID_RESOURCES
    else
      to_avoid = AVOID_CHARACTERS
    end
    avoid_types_cache[name] = to_avoid
  end
  return to_avoid
end

local function safe_position(name, stddev)
  local pos = random_position(stddev)
  if nauvis.can_place_entity{ name = "fish", position = pos} then
    return safe_position(name, stddev)
  end
  local colliding = nauvis.find_entities_filtered{
    type = avoid_types(name),
    area = {{pos.x-SAFE_RANGE,pos.y-SAFE_RANGE},{pos.x+SAFE_RANGE,pos.y+SAFE_RANGE}},
    limit = 1,
  }
  if colliding[1] then
    --[[
    log(serpent.line
    {
      msg="retry",
      name=name,
      cause_name = colliding[1].name,
      cause_position = colliding[1].position,
    })
    ]]
    return safe_position(name, stddev) end
  return pos
end

local function spawn_container()
  if not global.crashfx then global.crashfx = {} end
  global.crashfx.containers_spawned = (global.crashfx.containers_spawned or 0) + 1

  local name = "big-ship-wreck-"..global.crashfx.containers_spawned
  local position = safe_position(name, CONTAINER_STDDEV)
  local container = nauvis.create_entity{
    name = name,
    position = position,
    force = "neutral",
  }
  nauvis.create_entity{
    name = "massive-explosion",
    position = position,
    force = "neutral",
  }
  nauvis.create_entity{
    name = "ground-explosion",
    position = position,
    force = "neutral",
  }

  return container
end

local function spawn_wreckage(wreck)
  local position = safe_position(wreck.name, wreck.stddev)
  nauvis.create_entity{
    name = wreck.name,
    force = "neutral",
    position = position,
  }
  nauvis.create_entity{
    name = wreck.explosion,
    force = "neutral",
    position = position,
  }
  if random() < FIRE_PROB then
    nauvis.create_entity{
      name = "fire-flame-on-tree",
      position = position,
    }
  end
end

local function spawn_small()
end

local function run(tick)
  if not global.crashfx then
    global.crashfx = { containers_spawned = 0 }
  end
  if global.crashfx.containers_spawned >= NUM_CONTAINERS and tick > END_TIME then
    global.crashfx.done = true
    return false
  end
  if not nauvis then nauvis = game.surfaces.nauvis end

  local r = math.random()
  local time_factor = math.exp(-tick / DECAY)
  if r < CONTAINER_PROB and global.crashfx.containers_spawned < NUM_CONTAINERS then return spawn_container() end
  for i=1,#WRECKS do
    local wreck = WRECKS[i]
    if r < wreck.prob * time_factor then return spawn_wreckage(wreck) end
  end
end

return {
  run = run,
}

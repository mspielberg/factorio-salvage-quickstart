local wreckages = {
  "medium-ship-wreck",
  "small-ship-wreck",
  "small-scorchmark",
}

for _, name in pairs(wreckages) do
  local sqs_wreck = table.deepcopy(data.raw["simple-entity"][name] or data.raw["corpse"][name])
  sqs_wreck.name = "sqs-"..sqs_wreck.name
  sqs_wreck.minable = {mining_time = 2}
  data:extend{sqs_wreck}
end

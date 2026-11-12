local cases = require('cases')

local function report(event)
  log('BLUEPRINT_VALIDATION ' .. helpers.table_to_json(event))
  helpers.write_file('blueprint-validation.jsonl', helpers.table_to_json(event)..'\n', true)
end

local function first_position(entities)
  table.sort(entities, function(a,b)
    if a.position.x==b.position.x then return a.position.y<b.position.y end
    return a.position.x<b.position.x
  end)
  return entities[1].position
end

script.on_init(function()
  storage.tests={}
  for index,spec in ipairs(cases) do
    local force=game.create_force('blueprint-test-'..index)
    for _,recipe in pairs(force.recipes) do recipe.enabled=true end
    local surface=game.create_surface('blueprint-test-'..index,{width=256,height=256})
    surface.request_to_generate_chunks({0,0},5)
    surface.force_generate_chunk_requests()
    for _,entity in pairs(surface.find_entities()) do entity.destroy() end
    local tiles={}
    for x=-100,100 do for y=-100,100 do tiles[#tiles+1]={name='lab-dark-1',position={x,y}} end end
    surface.set_tiles(tiles)
    local inventory=game.create_inventory(1)
    assert(inventory[1].import_stack(spec.code)==0,'Import failed: '..spec.name)
    local expected=inventory[1].get_blueprint_entity_count()
    local ghosts=inventory[1].build_blueprint{surface=surface,force=force,position={0,0}}
    assert(#ghosts==expected,'Placement count mismatch: '..spec.name)
    for _,ghost in pairs(ghosts) do assert(ghost.revive{raise_revive=true},'Revival failed: '..spec.name) end
    assert(#surface.find_entities_filtered{name='entity-ghost'}==0,'Unrevived ghosts')
    local anchor_name=spec.blueprint_entities[1].name
    local originals={}
    for _,e in ipairs(spec.blueprint_entities) do if e.name==anchor_name then originals[#originals+1]=e end end
    local original=first_position(originals)
    local actual=first_position(surface.find_entities_filtered{name=anchor_name})
    local dx,dy=actual.x-original.x,actual.y-original.y
    local function at(p) return {x=p.x+dx,y=p.y+dy} end
    local energy=surface.create_entity{name='electric-energy-interface',position=at(spec.power.source),force=force}
    assert(energy,'Power fixture overlaps the blueprint')
    energy.power_production=100000000
    energy.electric_buffer_size=100000000
    energy.energy=100000000
    assert(surface.create_entity{name='small-electric-pole',position=at(spec.power.pole),force=force},'Power fixture pole overlaps')
    local test={spec=spec,surface=surface,belts={},fluids={},outputs={},collected={}}
    for _,input in ipairs(spec.belts or {}) do
      local entity=surface.find_entity(input.entity or 'transport-belt',at(input.position))
      assert(entity,'Missing belt input')
      test.belts[#test.belts+1]={entity=entity,spec=input}
    end
    for _,input in ipairs(spec.fluids or {}) do
      local entity=surface.find_entity(input.entity,at(input.position))
      assert(entity,'Missing fluid input')
      test.fluids[#test.fluids+1]={entity=entity,spec=input}
    end
    for i,output in ipairs(spec.outputs) do
      local containers=surface.find_entities_filtered{name=output.entity}
      assert(#containers>0,'Missing output containers')
      test.outputs[i]=containers
      test.collected[i]=0
    end
    storage.tests[index]=test
    report{event='import',name=spec.name,entities=expected,offset={x=dx,y=dy}}
    inventory.destroy()
  end
end)

script.on_event(defines.events.on_tick,function(event)
  for _,test in ipairs(storage.tests or {}) do
    local spec=test.spec
    for _,input in ipairs(test.belts) do
      if event.tick % input.spec.every_ticks==0 then
        for _,lane in ipairs(input.spec.lanes or {1,2}) do
          input.entity.get_transport_line(lane).insert_at_back{name=input.spec.item,count=1}
        end
      end
    end
    for _,input in ipairs(test.fluids) do
      if event.tick % (input.spec.every_ticks or 1)==0 then
        input.entity.insert_fluid{name=input.spec.name,amount=input.spec.amount}
      end
    end
    if event.tick % 60==0 then
      for i,output in ipairs(spec.outputs) do
        for _,container in pairs(test.outputs[i]) do
          test.collected[i]=test.collected[i]+container.remove_item{name=output.item,count=1000000}
        end
      end
    end
    if event.tick==spec.warmup_ticks then
      test.start={}
      for i,n in ipairs(test.collected) do test.start[i]=n end
    end
    if event.tick==spec.warmup_ticks+spec.sample_ticks then
      local outputs,passed={},true
      for i,output in ipairs(spec.outputs) do
        local rate=(test.collected[i]-test.start[i])*3600/spec.sample_ticks
        local ok=rate>=output.minimum_per_minute
        passed=passed and ok
        outputs[i]={item=output.item,collected_per_minute=rate,minimum_per_minute=output.minimum_per_minute,passed=ok}
      end
      report{event='result',name=spec.name,passed=passed,outputs=outputs}
      assert(passed,'Collected output below target: '..spec.name)
    end
  end
end)

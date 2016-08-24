--[[
  HTN Planner tutorial code for lecture at CEDEC2016

  Copyright (c) 2016, Yohei Hase. All rights reserved.
  This source code is licensed under the MIT license.
]]


--------------------------------------------------
-- utility

function deepcopy(a)
	if type(a) == "table" then
		local copy = {}
		for key, var in next, a, nil do
			copy[key] = deepcopy(var)
		end
		return copy
	else
		return a
	end
end

function array_merge(a, b)
	local newArray = {table.unpack(a)}
	for i, var in ipairs(b) do
		table.insert(newArray, var)
	end
	return newArray
end

function print_plan(plan)
	if plan == false or plan == nil then
		print("not found")
	else
		for i, var in ipairs(plan) do
			print(i .. ": " .. table.concat(var, ", "))
		end
	end
end


--------------------------------------------------
-- HTN Planner

function htn(domain, state, tasks)
	return htn_internal(domain, state, tasks, {})
end

function htn_internal(domain, state, tasks, plan)
	if next(tasks) == nil then
		return plan
	end
	
	local task = table.remove(tasks, 1)
	local taskName = table.remove(task, 1)
	
	-- Primitive Task
	if domain.primitive[taskName] ~= nil then
		local newState = deepcopy(state)
		local res = domain.primitive[taskName](newState, table.unpack(task))
		if res == true then
			return htn_internal(domain, newState, tasks, array_merge(plan, {{taskName, table.unpack(task)}}))
		else
			return false
		end
	-- Compound Task
	elseif domain.compound[taskName] ~= nil then
		for i, func in ipairs(domain.compound[taskName]) do
			local res = func(state, table.unpack(task))
			if res ~= false then
				res = htn_internal(domain, state, array_merge(res, tasks), plan)
				if res ~= false then
					return res
				end
			end
		end
	end
	
	return false
end

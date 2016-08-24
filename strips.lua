--[[
  STRIPS Planner tutorial code for lecture at CEDEC2016

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

function table_merge(a, b)
	for key, var in next, b, nil do
		if type(var) == "table" then
			if a[key] == nil then
				a[key] = {}
			end
			table_merge(a[key], var)
		else
			a[key] = var
		end
	end
	return a
end

function permutation(array, n, prev)
	prev = prev or {}
	
	if n <= 0 then
		return {}
	end
	
	local list = {}
	
	for i = 1, #array do
		if contains(prev, array[i]) == false then
			local tmp = { table.unpack(prev) }
			table.insert(tmp, array[i])
			if n == 1 then
				table.insert(list, tmp)
			else
				local newList = permutation(array, n - 1, tmp)
				for i, var in ipairs(newList) do
					table.insert(list, var)
				end
			end
		end
	end
	
	return list
end

function contains(tbl, value)
	for key, var in next, tbl, nil do
		if var == value then
			return true
		end
	end
	return false
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

function print_state(s, tab)
	tab = tab or ""
	
	for key, var in next, s, nil do
		if type(var) == "table" then
			print(tab .. key .. ": ")
			print_state(var, tab .. " ")
		else
			print(tab .. key .. ": " .. tostring(var))
		end
	end
end


--------------------------------------------------
-- STRIPS Planner

function makeAction(precondition, effect, cost)
	cost = cost or 1
	return { precondition = precondition, effect = effect, cost = cost }
end

function addAction(domain, name, func, paramNum, paramList)
	paramNum = paramNum or 0
	
	local action
	if paramNum <= 0 then
		action = func()
		action.name = {name}
		table.insert(domain, action)
	end
	
	local list = permutation(paramList, paramNum)
	for key, var in next, list, nil do
		action = func(table.unpack(var))
		action.name = { name, table.unpack(var) }
		table.insert(domain, action)
	end
end

function getDiffState(dest, src)
	local diff = {}
	local count = 0
	
	src = src or {}
	
	for key, var in next, dest, nil do
		if type(var) == "table" then
			local tbl, cnt = getDiffState(var, src[key])
			if cnt > 0 then
				diff[key] = tbl
				count = count + cnt
			end
		elseif var ~= src[key] then
			diff[key] = var
			count = count + 1
		end
	end
	
	return diff, count
end

function getNeighborActions(domain, state)
	local actions = {}
	for key, var in next, domain, nil do
		if isInState(var.effect, state) then
			table.insert(actions, var)
		end
	end
	return actions
end

function isInState(a, b)
	local result = isInState_internal(a, b)
	return result ~= false and result > 0
end

function isInState_internal(a, b)
	b = b or {}
	
	local sameStateCount = 0
	for key, var in next, a, nil do
		if type(var) == "table" then
			local result = isInState_internal(var, b[key])
			if result == false then
				return false
			end
			sameStateCount = sameStateCount + result
		elseif b[key] ~= nil and var ~= b[key] then
			return false
		elseif var == b[key] then
			sameStateCount = sameStateCount + 1
		end
	end
	
	return sameStateCount
end

function isSameState(a, b)
	return isSameState_internal(a, b) and isSameState_internal(b, a)
end

function isSameState_internal(a, b)
	for key, var in next, b, nil do
		local eq = a[key] == var;
		if type(var) == "table" and type(a[key]) == "table" then
			eq = isSameState(a[key], b)
		end
		if eq == false then
			return false
		end
	end
	return true
end

function getIndex(list, node)
	for i, var in ipairs(list) do
		if var.act == node.act then
			if isSameState(var.diff, node.diff) then
				return i
			end
		end
	end
	return 0
end

function compareNode(a, b)
	return a.score < b.score
end

function searchPlan(domain, state, goal)
	-- Run the A* algorithm to find a valid plan
	local openList = {}
	local closeList = {}
	
	-- Search from the goal state
	local goalNode = { state=goal, act=nil, next=nil, cost=0 }
	goalNode.diff, goalNode.diffCount = getDiffState(goalNode.state, state)
	goalNode.score = goalNode.diffCount
	table.insert(openList, goalNode)
	
	while #openList > 0 do
		local node = table.remove(openList, 1)
		
		if node.diffCount == 0 then
			return node
		end
		
		table.insert(closeList, node)
		
		local neighbors = getNeighborActions(domain, node.state)
		for key, var in next, neighbors, nil do
			local newState = table_merge(getDiffState(node.state, var.effect), var.precondition)	-- current state - action's effect + action's precondition
			local diff, diffCount = getDiffState(newState, state)
			local newCost = node.cost + var.cost
			local newScore = newCost + diffCount
			local newNode = { state=newState, act=var, next=node, cost=newCost, score=newScore, diff=diff, diffCount=diffCount }
			
			local indexOpen = getIndex(openList, newNode)
			if indexOpen > 0 then
				if openList[indexOpen].score > newNode.score then
					openList[indexOpen] = newNode;
				end
			else
				local indexClose = getIndex(closeList, newNode)
				if indexClose == 0 then
					table.insert(openList, newNode)
				end
			end
		end
		
		table.sort(openList, compareNode)
	end
	
	return false
end

function strips(domain, state, goal)
	local node = searchPlan(domain, state, goal)
	if node == false then
		return false
	end
	local plan = {}
	while node.act ~= nil do
		table.insert(plan, node.act.name)
		node = node.next
	end
	return plan
end

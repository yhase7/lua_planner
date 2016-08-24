--[[
  HTN Planner tutorial code for lecture at CEDEC2016

  Copyright (c) 2016, Yohei Hase. All rights reserved.
  This source code is licensed under the MIT license.
]]


require("htn")


domain = { primitive={}, compound={} }

--------------------------------------------------
-- Primitive Task

-- テーブル上の a を手に持つ
domain.primitive.pickup = function(state, a)
	if state.hand == "" and state.isTop[a] == true and state.on[a] == "table" then
		state.hand = a
		state.isTop[a] = false
		state.on[a] = "hand"
		return true
	end
	return false
end

-- 手に持った a をテーブルの上に置く
domain.primitive.putdown = function(state, a)
	if state.hand == a then
		state.hand = ""
		state.isTop[a] = true
		state.on[a] = "table"
		return true
	end
	return false
end

-- 手に持った　a を b の上に置く
domain.primitive.stack = function(state, a, b)
	if state.hand == a and state.isTop[b] == true then
		state.hand = ""
		state.isTop[a] = true
		state.isTop[b] = false
		state.on[a] = b
		return true
	end
	return false
end

-- b の上の a を手に持つ
domain.primitive.unstack = function(state, a, b)
	if state.hand == "" and state.isTop[a] == true and state.on[a] == b then
		state.hand = a
		state.isTop[a] = false
		state.isTop[b] = true
		state.on[a] = "hand"
		return true
	end
	return false
end


--------------------------------------------------
-- Compound Task

domain.compound.achieve = {
	function(state, goal)
		-- テーブルから何段目かを取得する
		local getStepNum = function(block, goal)
			local b = block
			local i = 0
			while goal.on[b] ~= "table" do
				i = i + 1
				b = goal.on[b]
			end
			return i
		end
		
		local block, minStep = "", 10000
		for key, var in next, goal.on, nil do
			if state.on[key] ~= goal.on[key] then
				-- 目標の状態がテーブル上か
				if goal.on[key] == "table" then
					return {{"move", key, "table"}, {"achieve", goal}}
				end
				-- テーブルに近いか
				local step = getStepNum(key, goal)
				if step < minStep then
					block = key
					minStep = step
				end
			end
		end
		
		-- 目標の状態で一番下段に近いブロックを移動
		if minStep < 10000 then
			return {{"move", block, goal.on[block]}, {"achieve", goal}}
		end
		
		-- 目標を達成した
		return {}
	end
}

domain.compound.move = {
	function(state, a, b)
		if state.hand == a then
			if state.isTop[b] == true then
				return {{"put", a, b}}
			else
				return {{"clear", b}, {"put", a, b}}
			end
		elseif state.isTop[a] == false then
			return {{"clear", a}, {"move", a, b}}
		elseif b ~= "table" and state.isTop[b] == false then
			return {{"clear", b}, {"move", a, b}}
		else
			return {{"get", a}, {"put", a, b}}
		end
		return false
	end
}

domain.compound.clear = {
	function(state, a)
		if state.isTop[a] == false then
			for key, var in next, state.on, nil do
				if var == a then
					return {{"move", key, "table"}}
				end
			end
		end
		return false
	end
}

domain.compound.get = {
	function(state, a)
		if state.hand == "" and state.isTop[a] == true then
			if state.on[a] == "table" then
				return {{"pickup", a}}
			else
				return {{"unstack", a, state.on[a]}}
			end
		end
		return false
	end
}

domain.compound.put = {
	function(state, a, b)
		if state.hand == a then
			if b == "table" then
				return {{"putdown", a}}
			elseif state.isTop[b] == true then
				return {{"stack", a, b}}
			end
		end
		return false
	end
}


--------------------------------------------------
-- State

state = {}
state.hand = ""
state.on = { a="table", b="a", c="b" }
state.isTop = { a=false, b=false, c=true }

plan = htn(domain, state, {{"move", "a", "b"}})
print_plan(plan)

goal = {}
goal.hand = ""
goal.on = { a="b", b="c", c="table" }
goal.isTop = { a=true, b=false, c=false }

--plan = htn(domain, state, {{"achieve", goal}})
--print_plan(plan)

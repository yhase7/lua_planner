--[[
  STRIPS Planner tutorial code for lecture at CEDEC2016

  Copyright (c) 2016, Yohei Hase. All rights reserved.
  This source code is licensed under the MIT license.
]]


require("strips")


--------------------------------------------------
-- Action

-- テーブル上の a を手に持つ
function pickup(a)
	local pre = { hand = "", isTop = {}, on = {} }
	pre.isTop[a] = true
	pre.on[a] = "table"

	local effect = { hand = a, isTop = {}, on = {} }
	effect.isTop[a] = false
	effect.on[a] = "hand"

	return makeAction(pre, effect)
end

-- 手に持った a をテーブルの上に置く
function putdown(a)
	local pre = { hand = a, isTop = {}, on = {} }
	pre.isTop[a] = false
	pre.on[a] = "hand"

	local effect = { hand = "", isTop = {}, on = {} }
	effect.isTop[a] = true
	effect.on[a] = "table"

	return makeAction(pre, effect)
end

-- 手に持った　a を b の上に置く
function stack(a, b)
	local pre = { hand = a, isTop = {}, on = {} }
	pre.isTop[a] = false
	pre.isTop[b] = true
	pre.on[a] = "hand"

	local effect = { hand = "", isTop = {}, on = {} }
	effect.isTop[a] = true
	effect.isTop[b] = false
	effect.on[a] = b

	return makeAction(pre, effect)
end

-- b の上の a を手に持つ
function unstack(a, b)
	local pre = { hand = "", isTop = {}, on = {} }
	pre.isTop[a] = true
	pre.isTop[b] = false
	pre.on[a] = b

	local effect = { hand = a, isTop = {}, on = {} }
	effect.isTop[a] = false
	effect.isTop[b] = true
	effect.on[a] = "hand"

	return makeAction(pre, effect)
end


domain = {}
addAction(domain, "pickup", pickup, 1, {"a", "b", "c", "d"})
addAction(domain, "putdown", putdown, 1, {"a", "b", "c", "d"})
addAction(domain, "stack", stack, 2, {"a", "b", "c", "d"})
addAction(domain, "unstack", unstack, 2, {"a", "b", "c", "d"})


--------------------------------------------------
-- State

state = {}
state.hand = ""
state.on = { a="b", b="table" }
state.isTop = { a=true, b=false }

state2 = {}
state2.hand = ""
state2.on = { a="table", b="a", c="b" }
state2.isTop = { a=false, b=false, c=true }

goal = {}
goal.on = { b="a" }

goal2 = {}
goal2.on = { a="c" }

plan = strips(domain, state, goal)
--plan = strips(domain, state2, goal2)
print_plan(plan)

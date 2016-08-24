--[[
  STRIPS Planner tutorial code for lecture at CEDEC2016

  Copyright (c) 2016, Yohei Hase. All rights reserved.
  This source code is licensed under the MIT license.
]]


require("strips")


--------------------------------------------------
-- Action

-- 近接攻撃
function melee()
	local pre = { hasTarget = true, atTarget = true }
	local effect = { hasTarget = false, atTarget = false }

	return makeAction(pre, effect, 5)
end

-- 射撃
function shot()
	local pre = { hasTarget = true, hasAmmo = true, canSeeTarget = true }
	local effect = { hasTarget = false, canSeeTarget = false }

	return makeAction(pre, effect)
end

-- リロード
function reload()
	local pre = { hasAmmo = false, hasMagazine = true }
	local effect = { hasAmmo = true, hasMagazine = false }

	return makeAction(pre, effect)
end

-- ターゲットまで移動する
function moveToTarget()
	local pre = { atTarget = false }
	local effect = { atTarget = true }

	return makeAction(pre, effect)
end

-- 射撃可能な場所へ移動する
function moveToShootingPoint()
	local pre = { hasAmmo = true, canSeeTarget = false }
	local effect = { canSeeTarget = true }

	return makeAction(pre, effect)
end


domain = {}
addAction(domain, "melee", melee)
addAction(domain, "shot", shot)
addAction(domain, "moveToTarget", moveToTarget)
addAction(domain, "moveToShootingPoint", moveToShootingPoint)
addAction(domain, "reload", reload)


--------------------------------------------------
-- State

state = {}
state.hasTarget = true
state.hasAmmo = false
state.hasMagazine = true
state.canSeeTarget = false
state.atTarget = false

goal = {}
goal.hasTarget = false

plan = strips(domain, state, goal)
print_plan(plan)

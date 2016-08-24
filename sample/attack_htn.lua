--[[
  HTN Planner tutorial code for lecture at CEDEC2016

  Copyright (c) 2016, Yohei Hase. All rights reserved.
  This source code is licensed under the MIT license.
]]


require("htn")


domain = { primitive={}, compound={} }

--------------------------------------------------
-- Primitive Task

-- 近接攻撃
domain.primitive.melee = function(state)
	if state.hasTarget == true and state.atTarget == true then
		state.hasTarget = false
		state.atTarget = false
		return true
	end
	return false
end

-- 射撃
domain.primitive.shot = function(state)
	if state.hasTarget == true and state.hasAmmo == true and state.canSeeTarget == true then
		state.hasTarget = false
		state.canSeeTarget = false
		return true
	end
	return false
end

-- リロード
domain.primitive.reload = function(state)
	if state.hasAmmo == false and state.hasMagazine == true then
		state.hasAmmo = true
		state.hasMagazine = false
		return true
	end
	return false
end

-- ターゲットまで移動する
domain.primitive.moveToTarget = function(state)
	if state.atTarget == false then
		state.atTarget = true
		return true
	end
	return false
end

-- 射撃可能な場所へ移動する
domain.primitive.moveToShootingPoint = function(state)
	if state.hasAmmo == true and state.canSeeTarget == false then
		state.canSeeTarget = true
		return true
	end
	return false
end


--------------------------------------------------
-- Compound Task

-- ターゲットを倒す
domain.compound.killTarget = {
	-- 射撃
	function(state)
		return {{"prepareShooting"}, {"shot"}}
	end,
	-- 近接攻撃
	function(state)
		if state.atTarget == true then
			return {{"melee"}}
		end
		return {{"moveToTarget"}, {"melee"}}
	end
}

-- 射撃準備をする
domain.compound.prepareShooting = {
	function(state)
		if state.hasAmmo == false then
			if state.hasMagazine == true then
				return {{"reload"}, {"prepareShooting"}}
			else
				return false
			end
		elseif state.canSeeTarget == false then
			return {{"moveToShootingPoint"}, {"prepareShooting"}}
		end
		
		-- 準備完了
		return {}
	end
}


--------------------------------------------------
-- State

state = {}
state.hasTarget = true
state.hasAmmo = false
state.hasMagazine = true
state.canSeeTarget = false
state.atTarget = false

plan = htn(domain, state, {{"killTarget"}})
print_plan(plan)

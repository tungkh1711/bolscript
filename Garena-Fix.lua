local Region = "NA"
_G.GetRegion = function() return Region end
_G.BuffFix = true  -- Set this to true if OnApplyBuff don't work
--------------------------------------------------------------
if _G.BuffFix then
_G.BUFF_NONE = 0
_G.BUFF_GLOBAL = 1
_G.BUFF_BASIC = 2
_G.BUFF_DEBUFF = 3
_G.BUFF_STUN = 5
_G.BUFF_STEALTH = 6
_G.BUFF_SILENCE = 7
_G.BUFF_TAUNT = 8
_G.BUFF_SLOW = 10
_G.BUFF_ROOT = 11
_G.BUFF_DOT = 12
_G.BUFF_REGENERATION = 13
_G.BUFF_SPEED = 14
_G.BUFF_MAGIC_IMMUNE = 15
_G.BUFF_PHYSICAL_IMMUNE = 16
_G.BUFF_IMMUNE = 17
_G.BUFF_Vision_Reduce = 19
_G.BUFF_FEAR = 21
_G.BUFF_CHARM = 22
_G.BUFF_POISON = 23
_G.BUFF_SUPPRESS = 24
_G.BUFF_BLIND = 25
_G.BUFF_STATS_INCREASE = 26
_G.BUFF_STATS_DECREASE = 27
_G.BUFF_FLEE = 28
_G.BUFF_KNOCKUP = 29
_G.BUFF_KNOCKBACK = 30
_G.BUFF_DISARM = 31
    class 'BuffManager'
	
	AdvancedCallback:register('OnApplyBuff', 'OnRemoveBuff')
	
	function BuffManager:__init()
		self.heroes = {}
		self.buffs  = {}
		for i = 1, heroManager.iCount do
        	local hero = heroManager:GetHero(i)
       		table.insert(self.heroes, hero)
        	self.buffs[hero.networkID] = {}
    	end
    	AddTickCallback(function () self:Tick() end)
	end

	function BuffManager:Tick()
		for i, hero in ipairs(self.heroes) do
			for i = 1, hero.buffCount do
				local buff = hero:getBuff(i)
				if self:Valid(buff) then
					local info = {unit = hero, buff = buff, slot = i, sent = false, sent2 = false}
					if not self.buffs[hero.networkID][info.buff.name] then
						self.buffs[hero.networkID][info.buff.name] = info
					end
				end
			end
		end
		for nid, table in pairs(self.buffs) do
			for i, buffs in pairs(table) do
				local buff = buffs.buff
				if self:Valid(buff) and not buffs.sent then
					local buffinfo = {name = buff.name:lower(), slot = buff.slot, duration = (buff.endT - buff.startT), startTime = buff.startT, endTime  = buff.endT, stacks = 1, type = buff.type}
					AdvancedCallback:OnApplyBuff(buffs.source, buffs.unit, buffinfo)
					buffs.sent = true
				elseif not self:Valid(buff) and not buffs.sent2 then
					local buffinfo = {name = buff.name:lower(), slot = buff.slot, duration = (buff.endT - buff.startT), startTime = buff.startT, endTime = buff.endT, stacks = 0, type = buff.type}
					AdvancedCallback:OnRemoveBuff(buffs.unit, buffinfo)
					self.buffs[buffs.unit.networkID][buff.name] = nil
					buffs.sent2 = true
				end
			end
		end
	end

	function BuffManager:Valid(buff)
		return buff and buff.name and buff.startT <= GetGameTimer() and buff.endT >= GetGameTimer()
	end

	function BuffManager:HasBuff(unit, buffname)
		return self.buffs[unit.networkID][buffname]:lower() ~= nil
	end
	----------------------------
	Buffs = BuffManager()
end

local  addon, dark_addon = ...
local support = dark_addon.support
local iknow = support.iknow
local hook = dark_addon.environment.hooks
local soothed_unit
local MW = {}
local SB = {
VivaciousVivification = 392883, -- insta Vivify
JadeEmpowerment = 467317, -- aoe Crackilng Lightning 

Vivify = 116670,
SoothingMist = 115175,

EnvelopingMist = 124682,

Mist = 115151,
Mist_Buff = 119611,

ChiBurst = 123986, -- key

HealingCocoon = 116849,

RisingSunKick = 107428,
RisingSunKick2 = 467307,
BlackoutKick = 100784,
SpinningCraneKick = 101546,
CrackilngLightning = 117952,
TigerPalm = 100780,

ExpelHarm = 322101,

ManaTea = 115294,
StormTea = 116680,
SheiLu = 399491,

Yulon = 322118,
RedChiJi = 325197,
ReviveTranq = 115310,
ReviveTranq2 = 388615,
JadeStomp = 388193, -- key

JadeStatue = 115313,
PeaceRing = 116844,
NebesniyProvodnik = 443028,

}
-----------------------------------------------------
----------------- Base tables -----------------------
-----------------------------------------------------
local _Unit = {
    { key = 'player', text = 'Player' },
}
local _Keys = {
    {key='Empty',text='Unbound'},
    {key='control',text='Any:CTRL'},
    {key='lcontrol',text='Left CTRL'},
    {key='rcontrol',text='Right CTRL'},
    {key='alt',text='Any:ALT'},
    {key='lalt',text='Left ALT'},
    {key='ralt',text='Right ALT'},
	{key='shift',text='Any:SHIFT'},
    {key='lshift',text='Left SHIFT'},
    {key='rshift',text='Right SHIFT'},
}
-----------------------------------------------------


-----------------------------------------------------
----------------- Custom Functions ------------------
-----------------------------------------------------

local function CB_Keys(_table, items, IsItemUsed)
    local modifiedList = {}
    for i, v in ipairs(_table) do
        modifiedList[i] = v
    end
    if IsItemUsed and items then
        for _, item in ipairs(items) do
            table.insert(modifiedList, item)
        end
    end
    return modifiedList
end

-----------------------------------------------------

-----------------------------------------------------
----------------- Table items -----------------------
-----------------------------------------------------


local KB_Auto = CB_Keys(_Keys, {
	{ key = 'auto', text = 'Auto' },
}, true)

MW.Check = function(id)
	return iknow(id) and castable(id)
end
 
local function cstng()
    if UnitCastingInfo('player') or UnitChannelInfo('player') then
        return true
    end
    return false
end

local function _hp_sort(unit1, unit2)
	if not unit1 or not unit2 or unit1.health.percent_plus_incomingHeal == nil or unit2.health.percent_plus_incomingHeal == nil then return end
    return unit1.health.percent_plus_incomingHeal < unit2.health.percent_plus_incomingHeal
end


local function isValidUnit(unit, spellID)
    return not UnitIsDeadOrGhost(unit.unitID)
           and UnitIsConnected(unit.unitID)
           and not UnitPhaseReason(unit.unitID)
		   and castable(spellID)
           and unit.distance <= 40
end
setfenv(isValidUnit, dark_addon.environment.env) 

local function process_units(spellID, table_func)
    local _table = table_func(spellID)
	table.sort(_table, _hp_sort)
    for _, unit in ipairs(_table) do
        if isValidUnit(unit, spellID) then
            return unit, #_table
        end
    end
end
setfenv(process_units, dark_addon.environment.env)

local function buffable_processor(spellID)
    return process_units(spellID, support.buffable_table)
end
setfenv(buffable_processor, dark_addon.environment.env)

local function buffed_processor(spellID)
    return process_units(spellID, support.buffed_table)
end
setfenv(buffed_processor, dark_addon.environment.env)



MW.HealingUnit = function(unit, Vivify_Percent, SoothingMist_Percent, EnvelopingMist_Percent, HealingCocoon_Percent)

if iknow(SB.StormTea) and player.buff(116680).down and (unit.health.percent_plus_incomingHeal <= Vivify_Percent or unit.health.percent_plus_incomingHeal <= EnvelopingMist_Percent) then
	if castable(SB.StormTea) then cast(SB.StormTea) return true end
end

if player.buff(116680).up then
	if iknow(SB.Vivify) and unit.health.percent_plus_incomingHeal <= Vivify_Percent and castable(SB.Vivify) then
		cast(SB.Vivify, unit)
		return true
	end

	if iknow(SB.EnvelopingMist) and unit.health.percent_plus_incomingHeal <= EnvelopingMist_Percent and unit.buff(SB.EnvelopingMist).down and castable(SB.EnvelopingMist) then
		cast(SB.EnvelopingMist, unit)
		return true
	end
end

if iknow(SB.HealingCocoon) and unit.buff(SB.HealingCocoon).down and unit.health.percent_plus_incomingHeal <= HealingCocoon_Percent and castable(SB.HealingCocoon) then
	cast(SB.HealingCocoon, unit)
	return true
end

if iknow(SB.Mist) and unit.buff(SB.Mist_Buff).down and castable(SB.Mist) then
	cast(SB.Mist, unit)
	return true
end


if soothed_unit and iknow(SB.EnvelopingMist) and soothed_unit.health.percent_plus_incomingHeal <= EnvelopingMist_Percent and soothed_unit.buff(SB.EnvelopingMist).down and castable(SB.EnvelopingMist) then
	cast(SB.EnvelopingMist, soothed_unit)
	return true
end

if iknow(SB.Vivify) and unit.health.percent_plus_incomingHeal <= Vivify_Percent and castable(SB.Vivify) then
	cast(SB.Vivify, unit)
	return true
end

if spell(SB.SoothingMist).current and unit.health.percent_plus_incomingHeal >= Vivify_Percent then
		dark_addon.environment.hooks.stopcast()
		soothed_unit = nil
end

if iknow(SB.SoothingMist) and unit.health.percent_plus_incomingHeal <= SoothingMist_Percent and castable(SB.SoothingMist) then
	soothed_unit = unit;
	cast(SB.SoothingMist, unit)
	return true
end
end
 
MW.TankHealing = function()
	local _Vivify, _SoothingMist, _EnvelopingMist, _HealingCocoon = dark_addon.settings.fetch("Mistweaver_Tank_Vivify", 90), dark_addon.settings.fetch("Mistweaver_Tank_SoothingMist", 80), dark_addon.settings.fetch("Mistweaver_Tank_EnvelopingMist", 70), dark_addon.settings.fetch("Mistweaver_Tank_HealingCocoon", 40)
	local Yulon_check, Yulon_spin = dark_addon.settings.fetch("Mistweaver_Tank_Yulon.check", false), dark_addon.settings.fetch("Mistweaver_Tank_Yulon.spin", 45)
	
	if Yulon_check and iknow(SB.Yulon) and tank.health.percent_plus_incomingHeal <= Yulon_spin and castable(SB.Yulon) then
		cast(SB.Yulon, tank)
		return true
	end
	
	MW.HealingUnit(tank, _Vivify, _SoothingMist, _EnvelopingMist, _HealingCocoon) -- Vivify, SoothingMist, EnvelopingMist, cock)00
end

MW.HealingGroup = function()
local RedChiJi_check, RedChiJi_spin, RedChiJi_count = dark_addon.settings.fetch("Mistweaver_RedChiJi.check", false), dark_addon.settings.fetch("Mistweaver_RedChiJi.spin", 90), dark_addon.settings.fetch("Mistweaver_RedChiJiSP", 3)
local ReviveTranq_check, ReviveTranq_spin, ReviveTranq_count = dark_addon.settings.fetch("Mistweaver_ReviveTranq.check", false), dark_addon.settings.fetch("Mistweaver_ReviveTranq.spin", 90), dark_addon.settings.fetch("Mistweaver_ReviveTranqSP", 3)
local NebesniyProvodnik_check, NebesniyProvodnik_spin, NebesniyProvodnik_count = dark_addon.settings.fetch("Mistweaver_NebesniyProvodnik.check", false), dark_addon.settings.fetch("Mistweaver_NebesniyProvodnik.spin", 85), dark_addon.settings.fetch("Mistweaver_NebesniyProvodnikSP", 3)

if RedChiJi_check and iknow(SB.RedChiJi) and group.under(RedChiJi_spin, 40, true) >= RedChiJi_count and castable(SB.RedChiJi) then
	cast(SB.RedChiJi)
	return true
end


if NebesniyProvodnik_check and iknow(SB.NebesniyProvodnik) and group.under(NebesniyProvodnik_spin, 40, true) >= NebesniyProvodnik_count and castable(SB.NebesniyProvodnik) then
	cast(SB.NebesniyProvodnik)
	return true
end


if ReviveTranq_check then
	if iknow(SB.ReviveTranq) and group.under(ReviveTranq_spin, 40, true) >= ReviveTranq_count and castable(SB.ReviveTranq) then
		cast(SB.ReviveTranq)
		return true
	end

	if iknow(SB.ReviveTranq2) and group.under(ReviveTranq_spin, 40, true) >= ReviveTranq_count and castable(SB.ReviveTranq2) then
		cast(SB.ReviveTranq2)
		return true
	end
end

end

MW.Prio = function()
	local _Vivify, _SoothingMist, _EnvelopingMist, _HealingCocoon = dark_addon.settings.fetch("Mistweaver_Priority_Vivify", 35), dark_addon.settings.fetch("Mistweaver_Priority_SoothingMist", 60), dark_addon.settings.fetch("Mistweaver_Priority_EnvelopingMist", 55), dark_addon.settings.fetch("Mistweaver_Priority_HealingCocoon", 40)
	local ManaTea_Percent = dark_addon.settings.fetch("Mistweaver_Priority_ManaTea", 55);
	local SheiLu_10_Percent = dark_addon.settings.fetch("Mistweaver_Priority_SheiLu_10", 60);
	local SheiLu_5_Percent = dark_addon.settings.fetch("Mistweaver_Priority_SheiLu_5", 35);
	local Priority_ManaTea_Stcks = dark_addon.settings.fetch("Mistweaver_Priority_ManaTea_Stcks", 5);
	
	if player.buff(197919).up then

		if soothed_unit and soothed_unit.buff(115175).up and castable(SB.EnvelopingMist) then
			cast(SB.EnvelopingMist, soothed_unit)
			return true
		end

		if castable(SB.SoothingMist) then
			soothed_unit = lowest;
			cast(SB.SoothingMist, lowest)
			return true
		end

	end
	
	if iknow(SB.ManaTea) and (player.buff(SB.ManaTea).count >= Priority_ManaTea_Stcks or player.buff(115867).count >= Priority_ManaTea_Stcks) and player.power.mana.percent <= ManaTea_Percent and castable(SB.ManaTea) then
		cast(SB.ManaTea)
		return true
	end

	if iknow(SB.SheiLu) and castable(SB.SheiLu) and (C_Spell.GetSpellCastCount(399491) >= 10 and lowest.health.percent_plus_incomingHeal <= SheiLu_10_Percent or C_Spell.GetSpellCastCount(399491) >= 5 and lowest.health.percent_plus_incomingHeal <= SheiLu_5_Percent) then
		cast(SB.SheiLu, lowest)
		return true
	end
	
	if iknow(SB.Vivify) and lowest.health.percent_plus_incomingHeal <= 80 and player.buff(SB.VivaciousVivification) and castable(SB.Vivify) then
		cast(SB.Vivify, lowest)
		return true
	end
	
	MW.HealingUnit(tank, _Vivify, _SoothingMist, _EnvelopingMist, _HealingCocoon) -- Vivify, SoothingMist, EnvelopingMist, cock)00
end


MW.Healing = function()
	local _Vivify, _SoothingMist, _EnvelopingMist, _HealingCocoon = dark_addon.settings.fetch("Mistweaver_Vivify", 90), dark_addon.settings.fetch("Mistweaver_SoothingMist", 80), dark_addon.settings.fetch("Mistweaver_EnvelopingMist", 70), dark_addon.settings.fetch("Mistweaver_HealingCocoon", 40)
	local Yulon_check, Yulon_spin = dark_addon.settings.fetch("Mistweaver_Yulon.check", false), dark_addon.settings.fetch("Mistweaver_Yulon.spin", 45)
	
	if Yulon_check and iknow(SB.Yulon) and lowest.health.percent_plus_incomingHeal <= Yulon_spin and castable(SB.Yulon) then
		cast(SB.Yulon, lowest)
		return true
	end
 
	MW.HealingUnit(lowest, _Vivify, _SoothingMist, _EnvelopingMist, _HealingCocoon) -- Vivify, SoothingMist, EnvelopingMist, cock 0)00
end

MW.Buffer = function()
	if iknow(SB.Mist) then
		local _Mist = buffable_processor(SB.Mist_Buff);
		if _Mist and castable(SB.Mist) and (_Mist.health.percent_plus_incomingHeal <= 95 or (player.buff(389422).up or player.buff(343820).up and player.buff(343820).count >= 3 or player.buff(343820).up and player.buff(343820).count < 3 and player.buff(343820).remains < 3)) then
			cast(SB.Mist, _Mist)
			return true
		end
	end
	if iknow(446326) then
		local _DzenImpulse = buffed_processor(446334);
		if _DzenImpulse then
			cast(SB.Vivify, _DzenImpulse)
			return true
		end
	end
end
 
MW.Keybinds = function()
	local ChiBurst = dark_addon.settings.fetch('Mistweaver_ChiBurst')
	local JadeStomp = dark_addon.settings.fetch('Mistweaver_JadeStomp')
	local PeaceRing = dark_addon.settings.fetch('Mistweaver_PeaceRing')
	local JadeStatue = dark_addon.settings.fetch('Mistweaver_JadeStatue')

	if hook.modifier[PeaceRing] and iknow(SB.PeaceRing) and castable(SB.PeaceRing) then
		cast(SB.PeaceRing, 'cursor')
		return true		
	end

	if hook.modifier[JadeStatue] and iknow(SB.JadeStatue) and castable(SB.JadeStatue) then
		cast(SB.JadeStatue, 'cursor')
		return true
	end
	
	if hook.modifier[ChiBurst] and castable(SB.ChiBurst) then
		cast(SB.ChiBurst)
		return true
	end

	if hook.modifier[JadeStomp] and castable(SB.JadeStomp) then
		cast(SB.JadeStomp)
		return true
	end

end
 
MW.Damage = function(EC)
if target.exists and target.enemy and target.alive then
local ChiBurst = dark_addon.settings.fetch('Mistweaver_ChiBurst')
local JadeStomp = dark_addon.settings.fetch('Mistweaver_ChiBurst')

if MW.Check(SB.RisingSunKick) then
	if toggle('cooldowns', false) and iknow(SB.StormTea) and player.buff(116680).down  then
		if castable(SB.StormTea) then cast(SB.StormTea) return true end
	end
	cast(SB.RisingSunKick, target)
	return true
end

if MW.Check(SB.RisingSunKick2) then
	if toggle('cooldowns', false) and iknow(SB.StormTea) and player.buff(116680).down  then
		if castable(SB.StormTea) then cast(SB.StormTea) return true end
	end
	cast(SB.RisingSunKick2, target)
	return true
end

if JadeStomp == 'auto' and UnitAffectingCombat('player') and castable(SB.JadeStomp) then
	cast(SB.JadeStomp)
	return true
end

if ChiBurst == 'auto' and UnitAffectingCombat('player') and castable(SB.ChiBurst) then
	cast(SB.ChiBurst)
	return true
end

if player.buff(SB.JadeEmpowerment).up and MW.Check(SB.CrackilngLightning) then
	cast(SB.CrackilngLightning, target)
	return true
end


if EC >= 2 and player.buff(389387).up and MW.Check(SB.BlackoutKick) then
	cast(SB.BlackoutKick, target)
	return true
end

if (EC >= 2 or player.buff(438443).up) and MW.Check(SB.SpinningCraneKick) then
	cast(SB.SpinningCraneKick, target)
	return true
end

if iknow(450870) and (player.buff(202090).down or player.buff(202090).up and player.buff(202090).count < 4) then
	cast(SB.TigerPalm)
	return true
end

if MW.Check(SB.BlackoutKick) then
	cast(SB.BlackoutKick, target)
	return true
end

end
end

MW.Worker = function()
	if spell(SB.SoothingMist).current then
		local sooth_unit = buffed_processor(SB.SoothingMist);
		soothed_unit = sooth_unit
	else
		soothed_unit = nil
	end
end

MW.Dispels = function()
if not toggle("dispel", false) then return end

local unit = group.dispellable(115450)

if unit and castable(115450) then -- cleaning party simulator 2024
	cast(115450, unit)
	return true
end
end

MW.Interrupt = function()
if not toggle("interrupts", false) then return end
	local low = dark_addon.settings.fetch("Mistweaver_intpercentlow", 10)
	local intpercent = math.random(low, low+10)
	
    if iknow(116705) and castable(116705, "target") and target.interrupt(intpercent, false) and target.distance <= 8 then
		cast(116705, "target")
		return true
    end
end

local function combat()
	local EC = enemies.around(30)
	if EC < 0 then EC = 1 end
	MW.Worker();

	
	
	if spell(115294).current then return end
	if spell(117952).current then return end
	
	if player.buff(406220).up then
		if MW.Check(SB.RisingSunKick) then
			cast(SB.RisingSunKick)
			return true
		end
		
		if MW.Check(SB.RisingSunKick2) then
			cast(SB.RisingSunKick)
			return true
		end
	end
	if MW.Keybinds() then return end
	if MW.Dispels() then return end
	if MW.HealingGroup() then return end
	if MW.Buffer() then return end
	if MW.Prio() then return end
	if MW.TankHealing() then return end

	if MW.Healing() then return end
	if MW.Interrupt() then return end
	if MW.Damage(EC) then return end
	
end

local function gcd()
	MW.Worker();
end

 
local function resting()
	MW.Worker();
	if MW.Keybinds() then return end
end

 
function interface()
  local mw_gui = {
    key = 'Mistweaver',
    title = 'Mistweaver',
    width = 420,
    height = 620,
    resize = true,
    show = false,
    template = {
	{ type = "header", text = "Mistweaver Monk", align='center' },
	
	{ type = "rule" },
	{ type = "header", text = "Keybinds", align='center' },
	
	{ key = "ChiBurst", type = "dropdown", tooltip = "Auto = in dps", text = FlexIcon(SB.ChiBurst, 22,22), default = "Empty", list = KB_Auto},
	{ key = "JadeStomp", type = "dropdown", tooltip = "Auto = in dps", text = FlexIcon(SB.JadeStomp, 22,22), default = "Empty", list = KB_Auto},
	{ key = "PeaceRing", type = "dropdown", text = FlexIcon(SB.PeaceRing, 22,22), default = "Empty", list = _Keys},
	{ key = "JadeStatue", type = "dropdown", text = FlexIcon(SB.JadeStatue, 22,22), default = "Empty", list = _Keys},
	
	{ type = "rule" },
	{ type = "header", text = "Group Healing", align='center' },
	
	{ key = "RedChiJi", type = "checkspin", text = FlexIcon(SB.RedChiJi, 22, 22)..' HP%', desc = "", default_check = false, default_spin = 90, min = 5, max = 100, step = 1 },
	{ key = 'RedChiJiSP', type = 'spinner', text = FlexIconN(SB.RedChiJi, 25, 25) .. ' under HP% count', desc = '', default = 3, min = 0, max = 10,  step = 1},
	
	{ key = "ReviveTranq", type = "checkspin", text = FlexIconN(SB.ReviveTranq, 22, 22) .. " " .. FlexIconN(SB.ReviveTranq2, 22, 22)..' HP%', desc = "", default_check = false, default_spin = 85, min = 5, max = 100, step = 1 },
	{ key = 'ReviveTranqSP', type = 'spinner', text = FlexIconN(SB.ReviveTranq, 22, 22) .. " " .. FlexIconN(SB.ReviveTranq2, 22, 22)..' under HP% count', desc = '', default = 3, min = 0, max = 10,  step = 1},
	
	{ key = "NebesniyProvodnik", type = "checkspin", text = FlexIcon(SB.NebesniyProvodnik, 22, 22) .. ' HP%', desc = "", default_check = false, default_spin = 85, min = 5, max = 100, step = 1 },
	{ key = 'NebesniyProvodnikSP', type = 'spinner', text = FlexIconN(SB.NebesniyProvodnik, 22, 22) ..' under HP% count', desc = '', default = 3, min = 0, max = 10,  step = 1},

	{ type = "rule" },
	{ type = "header", tooltip = "Will start healing with this spells whenever\nlowest health under HP%", text = "Priority Healing", align='center' },
	{ key = 'Priority_ManaTea', type = 'spinner', text = FlexIcon(SB.ManaTea, 22, 22) .. " Mana%", desc = '', default = 55, min = 0, max = 100,  step = 1},
	{ key = 'Priority_ManaTea_Stcks', type = 'spinner', text = FlexIconN(SB.ManaTea, 22, 22) .. " Stacks", desc = '', default = 10, min = 0, max = 100,  step = 1},
	
	{ key = 'Priority_SheiLu_10', type = 'spinner', text = FlexIcon(SB.SheiLu, 22, 22) .. " HP%", desc = '', default = 60, min = 0, max = 100,  step = 1},
	{ key = 'Priority_SheiLu_5', type = 'spinner', text = FlexIcon(SB.SheiLu, 22, 22) .. " HP%", desc = '', default = 35, min = 0, max = 100,  step = 1},
	
	{ key = 'Priority_Vivify', type = 'spinner', text = FlexIcon(SB.Vivify, 22, 22) .. " HP%", desc = '', default = 35, min = 0, max = 100,  step = 1},
	{ key = 'Priority_SoothingMist', type = 'spinner', text = FlexIcon(SB.SoothingMist, 22, 22) .. " HP%", desc = '', default = 60, min = 0, max = 100,  step = 1},
	{ key = 'Priority_EnvelopingMist', type = 'spinner', text = FlexIcon(SB.EnvelopingMist, 22, 22) .. " HP%", desc = '', default = 55, min = 0, max = 100,  step = 1},
	{ key = 'Priority_HealingCocoon', type = 'spinner', text = FlexIcon(SB.HealingCocoon, 22, 22) .. " HP%", desc = '', default = 40, min = 0, max = 100,  step = 1},
	
	{ type = "rule" },
	{ type = "header", text = "Tank Healing", align='center' },
	{ key = "Tank_Yulon", type = "checkspin", text = FlexIcon(SB.Yulon, 22, 22)..' HP%', desc = "", default_check = false, default_spin = 45, min = 5, max = 100, step = 1 },
	{ key = 'Tank_Vivify', type = 'spinner', text = FlexIcon(SB.Vivify, 22, 22) .. " HP%", desc = '', default = 90, min = 0, max = 100,  step = 1},
	{ key = 'Tank_SoothingMist', type = 'spinner', text = FlexIcon(SB.SoothingMist, 22, 22) .. " HP%", desc = '', default = 80, min = 0, max = 100,  step = 1},
	{ key = 'Tank_EnvelopingMist', type = 'spinner', text = FlexIcon(SB.EnvelopingMist, 22, 22) .. " HP%", desc = '', default = 70, min = 0, max = 100,  step = 1},
	{ key = 'Tank_HealingCocoon', type = 'spinner', text = FlexIcon(SB.HealingCocoon, 22, 22) .. " HP%", desc = '', default = 40, min = 0, max = 100,  step = 1},
	
	{ type = "rule" },
	{ type = "header", text = "Party Healing", align='center' },
	{ key = "Yulon", type = "checkspin", text = FlexIcon(SB.Yulon, 22, 22)..' HP%', desc = "", default_check = false, default_spin = 45, min = 5, max = 100, step = 1 },
	{ key = 'Vivify', type = 'spinner', text = FlexIcon(SB.Vivify, 22, 22) .. " HP%", desc = '', default = 90, min = 0, max = 100,  step = 1},
	{ key = 'SoothingMist', type = 'spinner', text = FlexIcon(SB.SoothingMist, 22, 22) .. " HP%", desc = '', default = 80, min = 0, max = 100,  step = 1},
	{ key = 'EnvelopingMist', type = 'spinner', text = FlexIcon(SB.EnvelopingMist, 22, 22) .. " HP%", desc = '', default = 70, min = 0, max = 100,  step = 1},
	{ key = 'HealingCocoon', type = 'spinner', text = FlexIcon(SB.HealingCocoon, 22, 22) .. " HP%", desc = '', default = 40, min = 0, max = 100,  step = 1},
	
	{ type = 'rule' },
	{ type = 'header', text = 'Interrupt', align = 'CENTER'},

	{ key = "intpercentlow", type = "spinner", text = "From cast end %", default = "10", desc = "", min = 5, max = 90, step = 1 },	
    }
  }

  configWindow = dark_addon.interface.builder.buildGUI(mw_gui)

  dark_addon.interface.buttons.add_toggle({
    name = 'settings',
    label = 'Rotation Settings',
    font = 'dark_addon_icon',
    on = {
      label = dark_addon.interface.icon('cog'),
      color = dark_addon.interface.color.green,
      color2 = dark_addon.interface.color.green
    },
    off = {
      label = dark_addon.interface.icon('cog'),
      color = dark_addon.interface.color.red,
      color2 = dark_addon.interface.color.red
    },
    callback = function(self)
      if configWindow.parent:IsShown() then
        configWindow.parent:Hide()
      else
        configWindow.parent:Show()
      end
    end
  })
  
dark_addon.interface.buttons.add_toggle({
  name = "dispel",
  label = "Dispel\nON|OFF",
  font = "dark_addon_icon",
  on = {
    label = dark_addon.interface.icon("toggle-on"),
    color = dark_addon.interface.color.green,
    color2 = dark_addon.interface.color.green
  },
  off = {
    label = dark_addon.interface.icon("toggle-off"),
    color = dark_addon.interface.color.red,
    color2 = dark_addon.interface.color.red
  }
})
end

dark_addon.rotation.register({
  spec = dark_addon.rotation.classes.monk.mistweaver,
  name = 'mw',
  label = '|11.0.5',
  combat = combat,
  gcd = gcd,
  resting = resting,
  interface = interface
})

for _, func in pairs(MW) do
    setfenv(func, dark_addon.environment.env)
end

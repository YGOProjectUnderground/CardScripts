--Worm Zero
--Modified for CrimsonRemodels
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,false,false,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_WORM),4,99,{10026986,81254059})
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.contactlim,aux.TRUE,s.contactzone)
	--Increase ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Apply the effect of 1 Reptile "Worm" monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,{id,0})
	e3:SetCost(s.cost)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)	
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_WORM}
s.listed_names={10026986,81254059}
function s.contactzone()
	return SUMMON_TYPE_SPECIAL,0xff&0x60
end
function s.contactlim(e)
	return e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.matfil(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsMonster()
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfil,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,0,LOCATION_REMOVED+LOCATION_GRAVE,0,nil)*300
end

function s.cfilter(c,e,tp)
	if not (c:IsSetCard(SET_WORM) and c:IsMonster() and c:IsRace(RACE_REPTILE)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
		and c:IsHasEffect(TYPE_FLIP) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()) then 
		return false
	end
	local eff={c:GetCardEffect(TYPE_FLIP)}
	for _,teh in ipairs(eff) do
		local te=teh:GetLabelObject()
		local con=te:GetCondition()
		local tg=te:GetTarget()
		if (not con or con(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) 
			and (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then return true end
	end
	return false
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	e:SetLabelObject(g)
	Group.KeepAlive(g)	
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetFirst()
	tc:CreateEffectRelation(e)
	if tc and tc:IsRelateToEffect(e) then
		local eff={tc:GetCardEffect(TYPE_FLIP)}
		local te=nil
		local acd={}
		local ac={}
		for _,teh in ipairs(eff) do
			local temp=teh:GetLabelObject()
			local con=temp:GetCondition()
			local tg=temp:GetTarget()
			if (not con or con(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) 
				and (not tg or tg(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
				table.insert(ac,teh)
				table.insert(acd,temp:GetDescription())
			end
		end
		if #ac==1 then te=ac[1] elseif #ac>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
			op=Duel.SelectOption(tp,table.unpack(acd))
			op=op+1
			te=ac[op]
		end
		if not te then return end
		Duel.ClearTargetCard()
		local teh=te
		te=teh:GetLabelObject()
		local tg=te:GetTarget()
		local op=te:GetOperation()
		if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		Duel.BreakEffect()
		tc:CreateEffectRelation(te)
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if g then
			for etc in aux.Next(g) do
				etc:CreateEffectRelation(te)
			end
		end
		if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		tc:ReleaseEffectRelation(te)
		if g then
			for etc in aux.Next(g) do
				etc:ReleaseEffectRelation(te)
			end
		end
	end
	Group.DeleteGroup(e:GetLabelObject())
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

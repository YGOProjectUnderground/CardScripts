--Worm Falco
--Modified for CrimsonRemodels
local s,id=GetID()
function s.initial_effect(c)
	--FLIP: Activate one of the forbidden effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,CUSTOM_REGISTER_FLIP)
end
s.listed_series={SET_WORM}
function s.filter1(c)
	return c:IsFacedown()
end
function s.filter2(c)
	return c:IsFaceup() and c:IsSetCard(SET_WORM) and c:IsRace(RACE_REPTILE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		local g=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,0,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
	elseif op==2 then
		local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		local g=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,0,e:GetHandler())
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	elseif op==2 then
		local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,e:GetHandler())
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE,0,POS_FACEDOWN_DEFENSE,0)
	end
end
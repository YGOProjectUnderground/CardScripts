--Living Desert Biome
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.pztg)
	e1:SetOperation(s.pzop)
	c:RegisterEffect(e1)
    --negate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	aux.DoubleSnareValidity(c,LOCATION_SZONE)
    --Plant monsters cannot be destroyed by card effects
	local e3=Effect.CreateEffect(c)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
s.listed_series={0xf19}
--Add to pendulum zone
function s.pzfilter(c)
	return c:IsSetCard(0xf19) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.CheckPendulumZones(tp) end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--negate spell/trap once per turn
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0xf19),tp,LOCATION_MZONE,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
--Cannot be destroyed by card effect
function s.indtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
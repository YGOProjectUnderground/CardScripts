--Worm Barses
--Modified for CrimsonRemodels
local s,id=GetID()
function s.initial_effect(c)
	--Negate Spell/Trap or effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_WORM}
function s.filter1(c)
	return c:IsSetCard(SET_WORM) and c:IsRace(RACE_REPTILE) and c:IsFaceup()
end
function s.filter2(c)
	return c:IsSetWNebula() and c:IsFaceup()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) 
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) 
		and Duel.IsChainNegatable(ev)
		and (Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil)
		 or  Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_ONFIELD,0,1,nil))
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil) 
	or Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_ONFIELD,0,1,nil) then
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
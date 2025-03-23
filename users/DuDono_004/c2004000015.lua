-- Sparkwave's Haste
local s, id = GetID()
function s.initial_effect(c)
	-- activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	-- handtrap
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	-- protecc
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.indtg)
	e3:SetValue(s.imval)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsSetCard(SET_SPARKWAVE) and c:IsMonster() and c:IsAbleToHand()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then
    return Duel.IsExistingMatchingCard(s.filter, e:GetHandlerPlayer(), LOCATION_DECK, 0, 1, nil)
end
Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,e:GetHandlerPlayer(),LOCATION_DECK)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.indtg(e,c)
	return c:IsSetCard(0x2a7) and c:IsSpellTrap() and not c:IsCode(id)
end
function s.imval(e,re)
  return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end

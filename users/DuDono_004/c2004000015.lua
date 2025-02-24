-- Sparkwave's Haste
Duel.LoadScript("_load_.lua")
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
  --shuffle
  local e5 = Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_QUICK_O)
  e5:SetCode(EVENT_FREE_CHAIN)
  e5:SetCountLimit(1)
  e5:SetRange(LOCATION_SZONE)
  e5:SetCost(s.countcost)
  e5:SetTarget(s.counttg)
  e5:SetOperation(s.countop)
  c:RegisterEffect(e5)
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
	return c:IsSetCard(SET_SPARKWAVE) and c:IsSpellTrap() and c ~= e:GetHandler()
end
function s.imval(e,re)
  return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.countcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	local ct=Duel.SelectMatchingCard(tp,Card.AbleToDeckAsCost,tp,LOCATION_HAND,0,1,60,nil)
  Duel.SendtoDeck(ct,nil,SEQ_DECKSHUFFLE,REASON_COST)
	e:SetLabel(#ct)
end
function s.counttg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_SZONE,0,1,nil,2004000010) end
end
function s.countop(e,tp,eg,ep,ev,re,r,rp)
  local eng = Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_SZONE,0,1,1,nil,2004000010):GetFirst()
  local ct = e:GetLabel()
  eng:AddCounter(COUNTER_SPARKWAVE, ct)
end
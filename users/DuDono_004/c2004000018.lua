-- Sparkwave Jumpstart
local s, id = GetID()
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCost(s.cost)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)
  --place counters
  local e2 = Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1,id)
  e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.cotg)
	e2:SetOperation(s.coop)
	c:RegisterEffect(e2)
  --handtrap
  local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
  e3:SetCondition(aux.TRUE)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SPARKWAVE}
function s.filter(c)
	return c:IsSetCard(SET_SPARKWAVE) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,2,nil) end
	Duel.DiscardHand(tp,s.filter,1,1,REASON_COST+REASON_DISCARD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.cotg(e,tp,ep,eg,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_SZONE,0,1,nil,2004000010) end
end
function s.coop(e,tp,ep,eg,ev,re,r,rp)
  local engine = Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_SZONE,0,1,1,nil,2004000010):GetFirst()
  engine:AddCounter(COUNTER_SPARKWAVE,3)
end
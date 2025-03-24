-- Sparkwave Mellontikos
local s, id = GetID()
function s.initial_effect(c)
  -- link summon
  Link.AddProcedure(c,nil,2)
  c:EnableReviveLimit()
  -- foolish
  local e1 = Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetCategory(CATEGORY_TOGRAVE)
  e1:SetProperty(EFFECT_FLAG_DELAY)
  e1:SetCountLimit(1,{id,1})
  e1:SetCondition(s.foolcon)
  e1:SetTarget(s.fooltg)
  e1:SetOperation(s.foolop)
  c:RegisterEffect(e1)
  -- add counters
  local e2 = Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1,{id,2})
  e2:SetTarget(s.counttg)
  e2:SetOperation(s.countop)
  c:RegisterEffect(e2)
end
s.counter_place_list = {0x2a7}
function s.foolcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.foolfilter(c)
	return c:IsMonster() and c:IsAbleToGrave() and c:IsSetCard(SET_SPARKWAVE)
end
function s.fooltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.foolfilter,ep,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,ep,LOCATION_DECK)
end
function s.foolop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,ep,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(ep,s.foolfilter,ep,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

function s.counttg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_SZONE,0,1,nil,2004000010) end
end
function s.countop(e,tp,eg,ep,ev,re,r,rp)
  local engine = Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_SZONE,0,1,1,nil,2004000010):GetFirst()
  engine:AddCounter(COUNTER_SPARKWAVE,3)
end

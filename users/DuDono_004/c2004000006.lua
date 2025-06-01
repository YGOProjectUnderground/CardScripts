-- Pyjama Party of Happy Nemleria
local s, id = GetID()
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)
  -- protect eepy girl
  local e2=Effect.CreateEffect(c)

	e2:SetDescription(aux.Stringid(id,0))


	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_EXTRA,LOCATION_EXTRA)
	e2:SetTarget(s.etarget)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
  -- search
  local e3 = Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetCost(s.thcost)
  e3:SetTarget(s.thtg)
  e3:SetOperation(s.thop)
  c:RegisterEffect(e3)
  -- banish
  local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,0})
	e4:SetCondition(s.bancon)
	e4:SetTarget(s.bantg)
	e4:SetOperation(s.banop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_NEMLERIA}
s.listed_names={CARD_DREAMING_NEMLERIA}

function s.etarget(e,c)
	return c:IsFaceup() and c:IsCode(CARD_DREAMING_NEMLERIA)
end
function s.efilter(e,re)

	-- side note : Kashtira Unicorn can still try to banish Dreaming Nemleria, it just won't work.


	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.rmcfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end 
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmcfilter,tp,LOCATION_EXTRA,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmcfilter,tp,LOCATION_EXTRA,0,2,2,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(SET_NEMLERIA) and c:IsAbleToHand() and c:IsMonster()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.bancfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_EXTRA) and c:IsPreviousControler(tp) and c:IsPosition(POS_FACEDOWN)
end
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.bancfilter,1,nil,rp) and rp==e:GetHandlerPlayer()
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and (c:IsLocation(LOCATION_SZONE) or aux.SpElimFilter(c,true,true))
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then 
	return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil)
  end
  local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end

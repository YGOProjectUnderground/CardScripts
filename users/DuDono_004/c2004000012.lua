-- Sparkwave Bhavishy
local s, id = GetID()
function s.initial_effect(c)
    -- place engine
    local e0 = Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(2004000010,3))
    e0:SetType(EFFECT_TYPE_QUICK_O)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetHintTiming(TIMING_DRAW_PHASE, TIMING_DRAW_PHASE)
    e0:SetRange(LOCATION_HAND)
    e0:SetCost(s.engcost)
    e0:SetTarget(s.engtg)
    e0:SetOperation(s.engop)
    c:RegisterEffect(e0)
    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    e1:SetCountLimit(1, id)
    c:RegisterEffect(e1)
    local e2 = e1:Clone()
    e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3 = e1:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    -- negate
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_GRAVE+LOCATION_HAND+LOCATION_MZONE)
    e5:SetTarget(s.reptg)
	e5:SetValue(s.repval)
	e5:SetOperation(s.repop)
	c:RegisterEffect(e5)
end

function s.engcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and
        not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,2004000010) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.engtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,2004000010) end
end
function s.engop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK, 0, 1, nil, 2004000010)
    local tc = g:Select(tp, 1, 1, nil):GetFirst()
    Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
end

function s.thfilter(c)
    return c:IsSetCard(SET_SPARKWAVE) and c:IsAbleToHand() and c:IsSpellTrap()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.thfilter, e:GetHandlerPlayer(), LOCATION_DECK, 0, 1, nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,e:GetHandlerPlayer(),LOCATION_DECK)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE)
		and c:IsSetCard(SET_SPARKWAVE) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741)
		and eg:IsExists(s.filter,1,nil,tp) and e:GetHandler():IsAbleToRemove() end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.filter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
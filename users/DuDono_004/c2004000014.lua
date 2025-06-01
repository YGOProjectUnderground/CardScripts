-- Sparkwave Avenir
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
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DRAW + CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
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

function s.spfilter(c, e, tp, zone)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, tp, zone) and c:IsSetCard(SET_SPARKWAVE)
end
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsTurnPlayer(1-tp)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local zone = aux.GetMMZonesPointedTo(tp)
    local ct = Duel.GetLocationCount(tp, LOCATION_MZONE, tp, LOCATION_REASON_TOFIELD, zone)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
        ct = 1
    end
    if chkc then
        return chkc:IsLocation(LOCATION_HAND) and chkc:IsControler(tp) and s.spfilter(chkc, e, tp, zone)
    end
    if chk == 0 then
        return ct > 0 and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp, zone)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local zone = aux.GetMMZonesPointedTo(tp)
    local ct = Duel.GetLocationCount(tp, LOCATION_MZONE, tp, LOCATION_REASON_TOFIELD, zone)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
        ct = 1
    end
    if ct <= 0 then
        return
    end
    local ss = Duel.SelectMatchingCard(tp,s.spfilter, tp, LOCATION_HAND, 0, 1, ct, nil, e, tp, zone)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    if #ss==0 then return end
    local tc = ss:GetFirst()
    local noOfSS = 0
    for tc in aux.Next(ss) do
        Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP, zone)
        noOfSS = noOfSS + 1
    end
    Duel.SpecialSummonComplete()
    if Duel.Draw(tp, noOfSS, REASON_EFFECT) then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_SKIP_TURN)
        e1:SetTargetRange(1, 0)
        e1:SetReset(RESET_PHASE + PHASE_END + RESET_SELF_TURN)
        Duel.RegisterEffect(e1, tp)
    end
end
-- Sparkwave Mustaqbal
Duel.LoadScript("_load_.lua")
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
    e1:SetDescription(aux.Stringid(87774234, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- burn
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetTarget(s.burntg)
    e2:SetOperation(s.burnop)
    c:RegisterEffect(e2)
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

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == 1 - tp and e:GetHandler():IsPreviousLocation(LOCATION_DECK) and
               e:GetHandler():IsPreviousControler(tp)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.burntg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1000)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, 0, 0, tp, 1000)
end
function s.burnop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
-- Sparkwave Plasma
local s, id = GetID()
function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    -- link summon
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    -- skip turn
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE + PHASE_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.skipcon)
    e3:SetTarget(s.skiptg)
    e3:SetOperation(s.skipop)
    c:RegisterEffect(e3)
    --activate from hand
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_HAND)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_HAND)
    e4:SetCondition(s.handcon)
    e4:SetTarget(s.handtg)
    e4:SetOperation(s.handop)
    c:RegisterEffect(e4)
end

function s.spfilter(c,tp)
    return c:IsRace(RACE_THUNDER) and c:IsLinkSummonable() and Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPARKWAVE,c:GetLink(),REASON_EFFECT) and not c:IsPublic()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local c=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
    if not c then return end
    Duel.ConfirmCards(1-tp,c)
    Duel.BreakEffect()
    if Duel.RemoveCounter(tp,1,0,COUNTER_SPARKWAVE,c:GetLink(),REASON_EFFECT) then
        Duel.LinkSummon(tp,c)
    end
end

function s.skipcon(e, tp, eg, ep, ev, re, r, rp)
    return ep ~= tp
end
function s.skiptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function s.skipop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    if Duel.Draw(p, d, REASON_EFFECT) then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_SKIP_TURN)
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE + PHASE_END + RESET_SELF_TURN)
        Duel.RegisterEffect(e1, tp)
    end
end
function s.handcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == 1 - tp and e:GetHandler():IsPreviousLocation(LOCATION_DECK) and
               e:GetHandler():IsPreviousControler(tp)
end
function s.handtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckLocation(tp, LOCATION_SZONE, 5)
    end
end
function s.handop(e, tp, eg, ep, ev, re, r, rp, chk)
    Duel.MoveToField(e:GetHandler(), tp, tp, LOCATION_FZONE, POS_FACEUP, true)
end
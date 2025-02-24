-- Sparkwave Futurum
Duel.LoadScript("_load_.lua")
local s, id = GetID()
function s.initial_effect(c)
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_THUNDER),2)
    c:EnableReviveLimit()
    -- own summon effect
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_SINGLE)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.ssptg)
    e1:SetOperation(s.sspop)
    c:RegisterEffect(e1)
    -- draw on link summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_TRIGGER_F + EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
    -- link during opp's turn
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(65741786, 0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
function s.ssptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function s.sspop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end
function s.drcon(e, tp, eg, ep, ev, re, r, rp)
    local tg = eg:GetFirst()
    return #eg == 1 and tg ~= e:GetHandler() and tg:GetSummonType() == SUMMON_TYPE_LINK and rp ==
               e:GetHandler():GetControler() and rp ~= Duel.GetTurnPlayer() and tg:IsSetCard(SET_SPARKWAVE)
end
function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function s.drop(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == 1 - tp and Duel.IsMainPhase()
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsLinkSummonable, tp, LOCATION_EXTRA, 0, 1, nil, nil) and
                   e:GetHandler():GetFlagEffect(id) == 0
    end
    e:GetHandler():RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsLinkSummonable, tp, LOCATION_EXTRA, 0, nil, nil)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg = g:Select(tp, 1, 1, nil)
        Duel.LinkSummon(tp, sg:GetFirst(), nil)
    end
end
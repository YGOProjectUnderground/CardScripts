-- Sparkwave Engine
Duel.LoadScript("_load_.lua")
local s, id = GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_SPARKWAVE)
    -- can only control 1
    c:SetUniqueOnField(1, 0, id)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    -- add counter
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetOperation(aux.chainreg)
    c:RegisterEffect(e2)
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    e3:SetCode(EVENT_CHAIN_SOLVED)
    e3:SetRange(LOCATION_SZONE)
    e3:SetOperation(s.acop)
    c:RegisterEffect(e3)
    -- local e4 = Effect.CreateEffect(c)
    -- e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    -- e4:SetRange(LOCATION_SZONE)
    -- e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    -- e4:SetOperation(s.sop)
    -- c:RegisterEffect(e4)
    -- local e41 = e4:Clone()
    -- e41:SetCode(EVENT_SUMMON_SUCCESS)
    -- c:RegisterEffect(e41)
    -- local e42 = e4:Clone()
    -- e42:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    -- c:RegisterEffect(e42)
    -- activate from hand
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e6:SetHintTiming(0xff)
    c:RegisterEffect(e6)
    -- summon
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,1))
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetRange(LOCATION_SZONE)
    e7:SetHintTiming(0xff)
    e7:SetTarget(s.sptg)
    e7:SetOperation(s.spop)
    c:RegisterEffect(e7)
    -- skip turn
    local e8 = Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,2))
    e8:SetCategory(CATEGORY_DRAW)
    e8:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e8:SetCode(EVENT_PHASE + PHASE_END)
    e8:SetRange(LOCATION_SZONE)
    e8:SetCountLimit(1)
    e8:SetCondition(s.skipcon)
    e8:SetTarget(s.skiptg)
    e8:SetOperation(s.skipop)
    c:RegisterEffect(e8)
end
function s.acop(e, tp, eg, ep, ev, re, r, rp)
    if re:IsActiveType(TYPE_SPELL + TYPE_TRAP + TYPE_MONSTER) and ep~=tp and e:GetHandler():GetFlagEffect(1)>0 then
        e:GetHandler():AddCounter(COUNTER_SPARKWAVE, 1)
    end
end
function s.sop(e, tp, eg, ep, ev, re, r, rp)
    if eg:IsExists(Card.IsSummonPlayer, 1, nil, 1 - tp) then
        e:GetHandler():AddCounter(COUNTER_SPARKWAVE, 1)
    end
end
function s.deckfilter(c)
    return c:IsDiscardable() and c:IsSetCard(SET_SPARKWAVE)
end
function s.deckfilter2(c, id)
    return c:IsCode(176490000)
end
function customComparator(n, bol)
    if bol then
        return n >= 1
    end
    if not bol then
        return n >= 0
    end
end
function s.filter(c, cc, e, tp)
    return c:IsSetCard(SET_SPARKWAVE) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and c:HasLevel() and
               cc:IsCanRemoveCounter(tp, COUNTER_SPARKWAVE, c:GetLevel(), REASON_COST)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local x = e:GetHandler():GetControler()
    if chk == 0 then
        return Duel.GetLocationCount(x, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.filter, x, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil, e:GetHandler(),
                e, x) and e:GetHandler():GetFlagEffect(id)==0
    end
    e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
    local g = Duel.GetMatchingGroup(s.filter, x, LOCATION_HAND + LOCATION_GRAVE, 0, nil, e:GetHandler(), e, x)
    local lvt = {}
    local tc = g:GetFirst()
    for tc in aux.Next(g) do
        local tlv = tc:GetLevel()
        lvt[tlv] = tlv
    end
    local pc = 1
    for i = 1, 12 do
        if lvt[i] then
            lvt[i] = nil
            lvt[pc] = i
            pc = pc + 1
        end
    end
    lvt[pc] = nil
    Duel.Hint(HINT_SELECTMSG, x, aux.Stringid(id, 0))
    local lv = Duel.AnnounceNumber(x, table.unpack(lvt))
    e:GetHandler():RemoveCounter(x, COUNTER_SPARKWAVE, lv, REASON_COST)
    e:SetLabel(lv)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, x, LOCATION_HAND + LOCATION_GRAVE)
end
function s.sfilter(c, lv, e, tp)
    return c:IsSetCard(SET_SPARKWAVE) and c:IsCanBeSpecialSummoned(e, 0, e:GetHandler():GetControler(), false, false) and c:GetLevel() == lv
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local x = e:GetHandler():GetControler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
        return
    end
    local lv = e:GetLabel()
    Duel.Hint(HINT_SELECTMSG, x, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(x, aux.NecroValleyFilter(s.sfilter), x, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1,
        nil, lv, e, x)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, x, x, false, false, POS_FACEUP)
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
        e1:SetTargetRange(1, 0)
        e1:SetReset(RESET_PHASE + PHASE_END + RESET_SELF_TURN)
        Duel.RegisterEffect(e1, tp)
    end
end
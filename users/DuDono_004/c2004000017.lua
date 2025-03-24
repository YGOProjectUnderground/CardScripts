-- Sparkwave Tulevaisuutta
local s, id = GetID()
function s.initial_effect(c)
    -- link procedure
    Link.AddProcedure(c, nil, 2, 5, s.lcheck)
    c:EnableReviveLimit()
    -- shuffle cards into the deck
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_SINGLE)
    e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetTarget(s.tortg)
    e1:SetOperation(s.torop)
    c:RegisterEffect(e1)
    -- gain attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.value)
    c:RegisterEffect(e2)
    -- do stuff
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND + CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e3:SetCountLimit(1)
    e3:SetCondition(s.condition)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
end
function s.lcheck2(c)
    return c:IsAttribute(ATTRIBUTE_WIND) or c:IsRace(RACE_THUNDER)
end
function s.lcheck(g, lc, sumtype, tp)
    return g:IsExists(s.lcheck2, 1, nil, lc, sumtype, tp)
end
function s.torcheck(c, tp)
    return (c:IsAbleToDeck() or c:IsAbleToExtra()) and c:IsControler(tp)
end
function s.tortg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED) and chkc:IsControler(tp) and
                   (chkc:IsAbleToDeck() or chkc:IsAbleToExtra())
    end
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.torcheck, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, tp)
    end
end
function s.torop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.SelectMatchingCard(tp, s.torcheck, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 99, nil, tp)
    if #g > 0 then
        Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end
function s.value(e)
    return Duel.GetCounter(e:GetHandlerPlayer(), 1, 0, COUNTER_SPARKWAVE) * 200
end
function s.condition(e)
    return Duel.GetTurnPlayer() ~= e:GetHandlerPlayer()
end
function s.tru(c)
    return true
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    local sel = 0
    local b1 = Duel.IsExistingTarget(s.tru, tp, 0, LOCATION_ONFIELD, 1, nil)
    local b2 = Duel.IsExistingMatchingCard(s.tru, tp, 0, LOCATION_ONFIELD, 1, nil)
    if chk == 0 then
        return true
    end
    local ct = 1
    if Duel.SelectYesNo(tp, aux.Stringid(id,0)) then
        ct = 2
    end
    local ops = {}
    local opval = {}
    local off = 1
    if b1 then
        ops[off] = aux.Stringid(id,1)
        opval[off - 1] = 1
        off = off + 1
    end
    if b2 then
        ops[off] = aux.Stringid(id,2)
        opval[off - 1] = 2
        off = off + 1
    end
    ops[off] = aux.Stringid(id,3)
    opval[off - 1] = 4
    off = off + 1
    local op = Duel.SelectOption(tp, table.unpack(ops))
    sel = sel + opval[op]
    if ct == 2 then
        sel = sel * 8
        ops = {}
        opval = {}
        off = 1
        if b1 then
            ops[off] = aux.Stringid(id,1)
            opval[off - 1] = 1
            off = off + 1
        end
        if b2 then
            ops[off] = aux.Stringid(id,2)
            opval[off - 1] = 2
            off = off + 1
        end
        ops[off] = aux.Stringid(id,3)
        opval[off - 1] = 4
        off = off + 1
        op = Duel.SelectOption(tp, table.unpack(ops))
        sel = sel + opval[op]
    end
    e:SetLabel(sel)
    if (sel & 2) ~= 0 or (sel & 16) ~= 0 then
        local g = Duel.GetMatchingGroup(s.tru, tp, 0, LOCATION_ONFIELD, nil)
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    end
    if (sel & 1) ~= 0 then
        local g = Duel.SelectTarget(tp, s.tru, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
        e:SetLabelObject(g:GetFirst())
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
    end
    if (sel & 8) ~= 0 then
        local g = Duel.SelectTarget(tp, s.tru, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
    end
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local sel = e:GetLabel()
    local targets = Duel.GetTargetCards(e)
    local ft = e:GetLabelObject()
    local st = nil
    if targets ~= nil then st = targets:GetFirst()
    if #targets == 2 and ft == st then st = targets:GetNext() end end
    if (sel & 1) ~= 0 then
        Duel.SendtoHand(ft, nil, REASON_EFFECT)
    end
    if (sel & 2) ~= 0 then
        local g = Duel.SelectMatchingCard(tp, s.tru, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
        Duel.Destroy(g, REASON_EFFECT)
    end
    if (sel & 4) ~= 0 then
        Duel.Damage(1 - tp, 800, REASON_EFFECT)
    end
    if (sel & 8) ~= 0 then
        Duel.SendtoHand(st, nil, REASON_EFFECT)
    end
    if (sel & 16) ~= 0 then
        local g = Duel.SelectMatchingCard(tp, s.tru, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
        Duel.Destroy(g, REASON_EFFECT)
    end
    if (sel & 32) ~= 0 then
        Duel.Damage(1 - tp, 800, REASON_EFFECT)
    end
    if sel >= 8 then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_SKIP_TURN)
        e1:SetTargetRange(1, 0)
        e1:SetReset(RESET_PHASE + PHASE_END + RESET_SELF_TURN)
        Duel.RegisterEffect(e1, tp)
    end
end

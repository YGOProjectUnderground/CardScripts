-- Sparkwave Ikusasa
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
    -- handtrap
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,1})
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    --Negate column
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,2})
    e2:SetOperation(s.negop)
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

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():IsAbleToGraveAsCost()
    end
    Duel.SendtoGrave(e:GetHandler(), REASON_COST)
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_SZONE, 0, 1, nil, 2004000010)
    end
end
function s.operation(e, tp, ep, eg, ev, re, r, rp)
    local engine = Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_SZONE, 0, 1, 1, nil, 2004000010):GetFirst()
    engine:AddCounter(COUNTER_SPARKWAVE, 3)
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g=c:GetColumnGroup()
    if chk == 0 then
        return #g > 0
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetColumnGroup()
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
        if tc:IsFaceup() then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1,true)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2,true)
        end
	end
end
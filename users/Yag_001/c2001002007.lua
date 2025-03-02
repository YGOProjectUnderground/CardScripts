--Shears of Severance
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Take control and allow for tribute
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.cttg)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)
    
    --Shuffle and add Divine Weaver of Atrophy to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

s.listed_names={2001002003} -- Divine Weaver of Atrophy

--Target filter for opponent's monsters
function s.ctfilter(c)
    return c:IsControlerCanBeChanged() and c:IsFaceup()
end

--Target function for control stealing
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

--Operation for control stealing
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp) then
        --Allow to be used as entire tribute for Ritual Summons with end of turn reset
        Ritual.AddWholeLevelTribute(tc,aux.TRUE,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
        
        --Destroy during End Phase
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetRange(LOCATION_MZONE)
        e2:SetCode(EVENT_PHASE+PHASE_END)
        e2:SetOperation(s.desop)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e2:SetCountLimit(1)
        tc:RegisterEffect(e2)
    end
end

-- These functions are no longer needed since we're using direct effects on the monster

--Destruction operation during End Phase
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

--Cost function for the GY effect (shuffle this card)
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end

--Target function for the GY effect
function s.thfilter(c)
    return c:IsCode(2001002003) and c:IsAbleToHand() and (c:IsLocation(LOCATION_REMOVED) or c:IsLocation(LOCATION_MZONE))
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,0,1,nil) end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,0,1,1,nil)
    
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

--Operation for the GY effect
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end
--Spindle of Divinity
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,0})
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)
    
    --Send a card from hand/field to GY to add Ritual Monster/Spell that is specifically listed on the discarded card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    
    --Shuffle and add Divine Weaver of Genesis to hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,{id,2})
    e3:SetCost(s.gycost)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end

s.listed_names={2001002006,2001002001} -- Domain of the Loom Sanctum, Divine Weaver of Genesis

--Filter for Domain of the Loom Sanctum
function s.setfilter(c)
    return c:IsCode(2001002006) and c:IsSSetable()
end

--Operation when card is activated
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and
       Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) and
       Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SSet(tp,g:GetFirst())
        end
    end
end

--Cost for the discard effect
function s.cfilterfordisc(c,tp)
    return c:IsAbleToGraveAsCost() and 
           Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilterfordisc,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilterfordisc,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
    e:SetLabelObject(g:GetFirst())
    Duel.SendtoGrave(g,REASON_COST)
end

--Check if a card is specifically listed on the discarded card
function s.thfilter(c,tc)
    return (c:IsRitualMonster() or c:IsRitualSpell()) and 
           tc:ListsCode(c:GetCode()) and
           c:IsAbleToHand()
end

--Target function for adding Ritual card specifically listed on the discarded card
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end -- Check is done in cost
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

--Operation for adding Ritual card specifically listed on the discarded card
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    
    local tc=e:GetLabelObject()
    if not tc then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--Cost function for the GY effect (shuffle this card)
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end

--Filter for Divine Weaver of Genesis in field or banished zone
function s.gyfilter(c)
    return c:IsCode(2001002001) and c:IsAbleToHand() and (c:IsLocation(LOCATION_REMOVED) or c:IsLocation(LOCATION_MZONE))
end

--Target function for the GY effect
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.gyfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,0,1,nil) end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,0,1,1,nil)
    
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

--Operation for the GY effect
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end
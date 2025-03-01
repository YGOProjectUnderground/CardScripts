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
    
    --Place on field when Divine Weaver of Genesis is Ritual Summoned
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.plcon)
    e3:SetTarget(s.pltg)
    e3:SetOperation(s.plop)
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

--Check if Divine Weaver of Genesis was Ritual Summoned
function s.cfilter(c,tp)
    return c:IsCode(2001002001) and c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsControler(tp)
end

--Condition for placing on field from GY
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end

--Target function for placing on field
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end

--Operation for placing on field
function s.plop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
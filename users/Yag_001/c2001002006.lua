--Domain of the Loom Sanctum
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
    
    --When a monster is Ritual Summoned - guess card in opponent's hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.guesscon)
    e2:SetTarget(s.guesstg)
    e2:SetOperation(s.guessop)
    c:RegisterEffect(e2)
    
    --Shuffle and add Divine Weaver of Fortune to hand
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

s.listed_names={2001002007,2001002002} -- Shears of Severance, Divine Weaver of Fortune

--Filter for Shears of Severance
function s.setfilter(c)
    return c:IsCode(2001002007) and c:IsSSetable()
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

--Filter for Ritual summoned monsters
function s.ritfilter(c,tp)
    return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsSummonPlayer(tp)
end

--Condition for guessing a card in opponent's hand
function s.guesscon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.ritfilter,1,nil,tp)
end

--Target function for guessing a card
function s.guesstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end

--Operation for guessing a card
function s.guessop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    
    --Announce a card name
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
    local ac=Duel.AnnounceCard(tp)
    
    --Opponent reveals hand and summons the monster if possible, otherwise sends to GY
    local g=Duel.GetMatchingGroup(Card.IsCode,1-tp,LOCATION_HAND,0,nil,ac)
    Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_HAND))
    
    local tc=g:GetFirst()
    if tc and tc:IsMonster() then
        if tc:IsCanBeSpecialSummoned(e,0,1-tp,false,false) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
            Duel.SpecialSummon(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
        else
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    end
    
    Duel.ShuffleHand(1-tp)
end

--Cost function for the GY effect (shuffle this card)
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end

--Filter for Divine Weaver of Fortune in field or banished zone
function s.gyfilter(c)
    return c:IsCode(2001002002) and c:IsAbleToHand() and (c:IsLocation(LOCATION_REMOVED) or c:IsLocation(LOCATION_MZONE))
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
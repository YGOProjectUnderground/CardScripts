--Wraith Raven of Ill Fate
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Must be Special Summoned by its own effect
    c:EnableReviveLimit()
    
    --Equipped monster has its effects negated and cannot be used as material
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_DISABLE)
    c:RegisterEffect(e1)
    
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e2:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
    c:RegisterEffect(e2)
    
    --Special Summon when a monster is Summoned
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    
    --Clone for different summon types
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
    
    local e5=e3:Clone()
    e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e5)
    
    --Special Summon when a card or effect is activated
    local e6=e3:Clone()
    e6:SetCode(EVENT_CHAINING)
    c:RegisterEffect(e6)
end

--Target for Special Summon from Spell/Trap Zone
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

--Operation for Special Summoning and applying additional effect
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    
    if Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)<=0 then return end
    
    --Apply one of three effects
    local opt=0
    local ft1=Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_SPELL+TYPE_TRAP)
    local ft2=Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    local ft3=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
    
    if ft1 and ft2 and ft3 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))+1
    elseif ft1 and ft2 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1
    elseif ft2 and ft3 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+1
        if opt==1 then opt=2 else opt=3 end
    elseif ft1 and ft3 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,3))+1
        if opt==2 then opt=3 end
    elseif ft1 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,1))+1
    elseif ft2 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1
        opt=2
    elseif ft3 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,3))+1
        opt=3
    else
        return
    end
    
    if opt==1 then
        --Send 1 Spell/Trap from Deck to GY
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL+TYPE_TRAP)
        if #g>0 then
            Duel.SendtoGrave(g,REASON_EFFECT)
        end
    elseif opt==2 then
        --Change Battle Position of 1 monster
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
        local g=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
        if #g>0 then
            Duel.ChangePosition(g:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
        end
    elseif opt==3 then
        --Banish 1 card from opponent's GY
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
        if #g>0 then
            Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
        end
    end
end
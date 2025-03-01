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
    
    --Set this card when Divine Weaver of Atrophy is Ritual Summoned
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
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
        --Register flag for Ritual Tribute
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
        
        --Allow to be used as entire tribute for Ritual Summon
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_RITUAL_LEVEL)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetLabelObject(tc)
        e1:SetTarget(s.ritualtarget)
        e1:SetValue(s.rituallevel)
        Duel.RegisterEffect(e1,tp)
        
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

--Target for the ritual level effect
function s.ritualtarget(e,c)
    return c:IsRitualMonster()
end

--Value for ritual level effect
function s.rituallevel(e,c)
    local tc=e:GetLabelObject()
    if tc:GetFlagEffect(id)~=0 then
        return 8 --Level value needed for our Ritual Monsters
    else
        return tc:GetLevel()
    end
end

--Destruction operation during End Phase
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

--Check if Divine Weaver of Atrophy was Ritual Summoned
function s.ritfilter(c,tp)
    return c:IsCode(2001002003) and c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsControler(tp)
end

--Condition for setting from GY
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.ritfilter,1,nil,tp)
end

--Target function for setting from GY
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end

--Operation for setting from GY
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSSetable() then
        Duel.SSet(tp,c)
    end
end
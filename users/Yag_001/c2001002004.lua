--Needle of Spun Fates
--Ritual Spell for Divine Weaver monsters
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    
    --Return to deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

s.listed_names={2001002001,2001002002,2001002003} --Divine Weaver monsters IDs
s.listed_series={0x79b}

--Helper function for ritual requirements (adapted from Divine Weaver of Genesis)
local function RitualCheck(sc,lv,forcedselection,_type,requirementfunc)
    local chk
    if _type==RITPROC_EQUAL then
        chk=function(g) return g:GetSum(requirementfunc or Card.GetRitualLevel,sc)>=lv end
    else
        chk=function(g,c) return g:GetSum(requirementfunc or Card.GetRitualLevel,sc) - (requirementfunc or Card.GetRitualLevel)(c,sc)>=lv end
    end
    return function(sg,e,tp,mg,c)
        local res=chk(sg,c)
        if not res then return false,true end
        local stop=false
        if forcedselection then
            local ret=forcedselection(e,tp,sg,sc)
            res=ret[1]
            stop=ret[2] or stop
        end
        if res and not stop then
            if _type==RITPROC_EQUAL then
                res=sg:CheckWithSumEqual(requirementfunc or Card.GetRitualLevel,lv,#sg,#sg,sc)
            else
                Duel.SetSelectedCard(sg)
                res=sg:CheckWithSumGreater(requirementfunc or Card.GetRitualLevel,lv,sc)
            end
            res=res and Duel.GetMZoneCount(tp,sg,tp)>0
        end
        return res,stop
    end
end

--Filter for monsters in GY that can be banished as material
function s.matfilter(c)
    return c:IsMonster() and c:HasLevel() and c:IsAbleToRemove()
end

--Filter for valid ritual monsters
function s.ritualfilter(c,e,tp,m,m2)
    if not (c:IsCode(2001002001,2001002002,2001002003) and c:IsRitualMonster()) then return false end
    if not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
    
    local lv=c:GetLevel()
    local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
    
    -- If checking a card in GY, don't include it in material calculation
    local mg2_filtered = m2:Clone()
    if c:IsLocation(LOCATION_GRAVE) then
        mg2_filtered:RemoveCard(c)
    end
    mg:Merge(mg2_filtered)
    
    if c.mat_filter then
        mg=mg:Filter(c.mat_filter,nil,tp)
    end
    
    return aux.SelectUnselectGroup(mg,e,tp,1,99,RitualCheck(c,lv,nil,RITPROC_EQUAL),0)
end

--Target function for ritual summoning
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetRitualMaterial(tp)
        local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil)
        
        return Duel.IsExistingMatchingCard(s.ritualfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,mg,mg2)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

--Set appropriate Spell/Trap after Ritual Summon
function s.settfilter(c,code)
    if not c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsType(TYPE_RITUAL) then return false end
    local codes={
        [2001002001]=2001002005, --Divine Weaver of Genesis -> Spindle of Divinity
        [2001002002]=2001002006, --Divine Weaver of Fortune -> Domain of the Loom Sanctum
        [2001002003]=2001002007, --Divine Weaver of Atrophy -> Shears of Severance
    }
    return c:IsCode(codes[code]) and c:IsSSetable()
end

--Activation operation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetRitualMaterial(tp)
    local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil)
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ritualfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,mg,mg2)
    
    if #tg>0 then
        local tc=tg:GetFirst()
        local lv=tc:GetLevel()
        
        -- Create material pool
        local mgf=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
        
        -- Remove the specific ritual monster from GY materials if it's being summoned from GY
        local mg2_filtered = mg2:Clone()
        if tc:IsLocation(LOCATION_GRAVE) then
            mg2_filtered:RemoveCard(tc)
        end
        mgf:Merge(mg2_filtered)
        
        if tc.mat_filter then
            mgf=mgf:Filter(tc.mat_filter,nil,tp)
        end
        
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        mat=aux.SelectUnselectGroup(mgf,e,tp,1,99,RitualCheck(tc,lv,nil,RITPROC_EQUAL),1,tp,HINTMSG_RELEASE)
        
        if #mat>0 then
            tc:SetMaterial(mat)
            
            --Process materials from different locations
            local mat_gy=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
            local mat_field=mat-mat_gy
            
            if #mat_gy>0 then
                Duel.Remove(mat_gy,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
            end
            if #mat_field>0 then
                Duel.Release(mat_field,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
            end
            
            Duel.BreakEffect()
            --Perform the ritual summon
            if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
                --Check if we should set a spell/trap
                if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
                    local g=Duel.GetMatchingGroup(s.settfilter,tp,LOCATION_DECK,0,nil,tc:GetCode())
                    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
                        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
                        local sg=g:Select(tp,1,1,nil)
                        if #sg>0 then
                            Duel.SSet(tp,sg)
                        end
                    end
                end
            end
        end
    end
end

--Shuffle self to deck cost
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end

--Target filter for field or banished "Divine Weaver" monster
function s.thfilter(c)
    return c:IsSetCard(0x79b) and c:IsMonster() and c:IsAbleToHand() and 
           (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_REMOVED))
end

--Target function for returning a "Divine Weaver" monster to hand
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

--Operation for returning "Divine Weaver" monster to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end
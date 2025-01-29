--リチュアの写魂鏡
--Gishki Photomirror
--Modified for CrimsonAlpha
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    if not s.ritual_matching_function then
        s.ritual_matching_function={}
    end
    s.ritual_matching_function[c]=aux.FilterEqualFunction(Card.IsSetCard,SET_GISHKI)
end
s.listed_series={SET_GISHKI}
-- custom --
function s.extralocfilter(c,e,tp,lp)
    if not c:IsRitualMonster() 
	or not c:IsSetCard(SET_GISHKI) 
	or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) 
	then
        return false
    end
	local extra_loc_eff,used=Ritual.ExtraLocationOPTCheck(c,e:GetHandler(),tp)
	if not extra_loc_eff or extra_loc_eff and used then return false end
	if extra_loc_eff:GetProperty()&EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN>0 
	and Duel.HasFlagEffect(tp,EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN) then 
		return false 
	end
	return lp>c:GetLevel()*500
end
function s.filter(c,e,tp,lp)
    if not c:IsRitualMonster() or not c:IsSetCard(SET_GISHKI) 
	or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then
        return false
    end
    return lp>c:GetLevel()*500
end
--
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local lp=Duel.GetLP(tp)
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp,lp)
			-- custom --
			 or Duel.IsExistingMatchingCard(s.extralocfilter,tp,LOCATION_NOTHAND,0,1,nil,e,tp,lp)
			--
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_NOTHAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local lp=Duel.GetLP(tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- custom --
	local tg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e,tp,lp)
	local extratg=Duel.GetMatchingGroup(s.extralocfilter,tp,LOCATION_NOTHAND,0,nil,e,tp,lp)
	tg=tg:Merge(extratg)
    local tc=tg:Select(tp,1,1,nil):GetFirst()
	local extra_loc_eff=Ritual.GetExtraLocationEffect(tc,e:GetHandler())
	if extra_loc_eff and extra_loc_eff:CheckCountLimit(tp) then
		local extra_loc=extra_loc_eff:GetTargetRange()
		if extra_loc_eff:GetType()&EFFECT_TYPE_SINGLE>0 or extra_loc and tc:IsLocation(extra_loc) then
			extra_loc_eff:UseCountLimit(tp)
			if extra_loc_eff:GetProperty()&EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN>0 then
				Duel.RegisterFlagEffect(tp,EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN,RESET_PHASE|PHASE_END,0,1)
			end
		end
	end
	--
    if tc then
        mustpay=true
        Duel.PayLPCost(tp,tc:GetLevel()*500)
        mustpay=false
        tc:SetMaterial(nil)
        Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
        tc:CompleteProcedure()
    end
end

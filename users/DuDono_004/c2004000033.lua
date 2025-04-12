-- Eclipse Observatory
Duel.LoadScript("_load_.lua")
local s, id = GetID()
function s.initial_effect(c)
	-- activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- banish
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
end

function s.filter(c)
	return c:IsSetCard(SET_ECLIPSE_OBSERVER) and c:IsMonster()
end
function s.filter2(c)
	return c:IsQuickPlaySpell() and c:IsSetCard(SET_ECLIPSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil) and
	Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and
	Duel.IsPlayerCanDraw(1-tp,2) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil)
		local g2=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and #g2>0 then
			local ac = g:Merge(g2)
			local nc = Duel.SendtoHand(ac,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,ac)
			if nc==2 then
				Duel.Draw(1-tp,2,REASON_EFFECT)
			end
		end
	end
end

function s.banfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e) and c:IsNegatableMonster()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.banfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.banfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=nil
	if #eg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=eg:FilterSelect(tp,s.banfilter,1,1,nil,e,tp):GetFirst()
	else
		tc=eg:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,2)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
		--Negate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsImmuneToEffect(e1) or tc:IsImmuneToEffect(e2) then return end
		Duel.AdjustInstantly(tc)
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
	Duel.BreakEffect()
	Duel.Draw(1-tp,2,REASON_EFFECT)
end

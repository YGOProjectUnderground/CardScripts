-- Book of Planetary Eclipse
local s, id = GetID()
function s.initial_effect(c)
	-- activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_DRAW + CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sc = Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)
	local oc = Duel.GetFieldGroupCount(1-tp,LOCATION_EXTRA,0)
	if chk==0 then
		return (sc > oc and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,sc-oc,nil)) or (sc < oc and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,oc-sc,nil))
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local sc = Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)
	local oc = Duel.GetFieldGroupCount(1-tp,LOCATION_EXTRA,0)
	local dif = sc-oc
	if dif==0 then return end
	if dif>0 then
		--you send
		local dg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,nil)
		if #dg>=dif then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local tg=dg:Select(tp,dif,dif,nil)
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(s.srcon)
		e1:SetOperation(s.srop)
		Duel.RegisterEffect(e1,tp)
	end
	if dif<0 then
		dif = -dif
		--your opponent's send
		local dg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
		if #dg>=dif then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
			local tg=dg:Select(1-tp,dif,dif,nil)
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetCondition(s.orcon)
		e2:SetOperation(s.orop)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.srcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsAbleToExtra,tp,LOCATION_GRAVE,0,1,nil)
end
function s.srop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToExtra,tp,LOCATION_GRAVE,0,1,nil)
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.Draw(1-tp,ct,REASON_EFFECT)
end
function s.orcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsAbleToExtra,tp,0,LOCATION_GRAVE,1,nil)
end
function s.orop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToExtra,tp,0,LOCATION_GRAVE,1,nil)
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.Draw(1-tp,ct,REASON_EFFECT)
end

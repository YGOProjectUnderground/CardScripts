-- Grimoire of Eclipse
Duel.LoadScript("_load_.lua")
local s, id = GetID()
function s.initial_effect(c)
	-- activate
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_ECLIPSE_OBSERVER}

function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
	if #eg>0 then
		return eg,s.fcheck
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
function s.flipfilter(c)
	return c:IsFaceup()
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==3 then
		local mats=sg:Filter(Card.IsPreviousLocation,nil,LOCATION_DECK)
		if #mats > 0 then
			Duel.Draw(1-tp,2,REASON_EFFECT)
		end
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_ECLIPSE_OBSERVER),extrafil=s.fextra,extratg=s.extratg,stage2=s.stage2}
	--Fusion Summon
	local b1=Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	--Flip the banished cards cause lol
	local b2=Duel.IsExistingMatchingCard(s.flipfilter,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_DRAW)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Fusion Summon 1 "Gem-Knight" Fusion Monster from your Extra Deck, using monsters from your hand or field as material
		local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_ECLIPSE_OBSERVER),extrafil=s.fextra,stage2=s.stage2}
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		--Flip the cards face-down
		local tc=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_REMOVED,nil)
		Duel.SendtoGrave(tc,REASON_EFFECT|REASON_RETURN)
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
		--Flip the cards face-up
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_REMOVED,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_REMOVED,nil)
	Duel.SendtoGrave(g,REASON_EFFECT|REASON_RETURN)
	local d=Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end

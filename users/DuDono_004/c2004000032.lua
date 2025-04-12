-- Tome of Eclipse
Duel.LoadScript("_load_.lua")
local s, id = GetID()
function s.initial_effect(c)
	-- activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_DRAW + CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.filter(c)
	return c:IsSpellTrap() and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_SZONE+LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_SZONE+LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,#g)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_SZONE+LOCATION_GRAVE,nil)
	local c=e:GetHandler()
	local d=0
	for tc in aux.Next(g) do
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetRange(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetOperation(s.retop)
			tc:RegisterEffect(e1)
			d=d+1
		end
	end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_RETURN)
end

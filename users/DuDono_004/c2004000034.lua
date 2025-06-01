-- Eclipse Observer Riley
local s, id = GetID()
function s.initial_effect(c)
	-- search
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.searchtg)
	e1:SetOperation(s.searchop)
	c:RegisterEffect(e1)
	-- grab back eclipse
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCode(EVENT_DRAW)
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

function s.searchfilter(c,e,tp,ft)
	return c:IsSetCard(SET_ECLIPSE_OBSERVER) and ((ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) or c:IsAbleToHand())
end
function s.searchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and chkc:IsControler(tp) and s.searchfilter(chkc,e,tp,ft) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.searchfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,2)
end
function s.searchop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g = Duel.SelectMatchingCard(tp,s.searchfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft):GetFirst()
	aux.ToHandOrElse(g,tp,
		function()
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			Duel.Draw(1-tp,2,REASON_EFFECT)
		end,
		aux.Stringid(id,1) --"Special Summon it"
	)
end

function s.gyfilter(c)
	return c:IsQuickPlaySpell() and c:IsSetCard(SET_ECLIPSE) and c:IsAbleToHand()
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and ev>=2
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
end

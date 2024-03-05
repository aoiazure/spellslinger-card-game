## Tracks a Fighter's state during a duel.
class_name PlayerClashState extends ClashState



signal hand_updated(hand)
signal deck_updated(deck)
signal grave_updated(grave)

signal limbs_updated(cur, max)
signal mouth_updated(cur, max)

### Stats
var max_limbs: int = 2 :
	set(val):
		max_limbs = val
		limbs_updated.emit(num_limbs, max_limbs)
var num_limbs: int = 2 :
	set(val):
		num_limbs = val
		limbs_updated.emit(num_limbs, max_limbs)

var max_mouth: int = 1 :
	set(val):
		max_mouth = val
		mouth_updated.emit(num_mouth, max_mouth)
var num_mouth: int = 1 :
	set(val):
		num_mouth = val
		mouth_updated.emit(num_mouth, max_mouth)

### Zones

## What cards are in the hand.
var hand: Array[CardModel] = []
## What cards are left in the deck.
var deck: Array[CardModel] = []
## What cards have been used already. The graveyard.
var grave: Array[CardModel] = []



static func create(
		_cur: int, _max: int,
		_deck: Array[CardModel], _statuses: Array[StatusModel] = []
		) -> PlayerClashState:
	
	var state:= PlayerClashState.new()
	state.cur_hp = _cur
	state.max_hp = _max
	state.deck = _deck.duplicate(true)
	state.deck.shuffle()
	state.statuses = _statuses
	
	return state

func start_upkeep() -> void:
	var limbs: int = max_limbs
	var mouths: int = max_mouth
	for status in statuses:
		if status.affects_limbs_count:
			limbs += status.strength
		if status.affects_mouth_count:
			mouths += status.strength
	num_limbs = limbs
	num_mouth = mouths
	
	var amount: int = 5 - hand.size()
	for status: StatusModel in statuses:
		if status is StatusModel.DrawMoreStartTurn:
			amount += status.strength
	
	draw_card(maxi(amount, 1))

func end_turn() -> void:
	pass


func draw_card(amount: int = 1) -> void:
	for status: StatusModel in statuses:
		if status is StatusModel.DrawMore:
			pass
	
	for i in maxi(amount, 0):
		if deck.is_empty():
			if not grave.is_empty():
				print("Deck empty, shuffling grave into deck.")
				deck.append_array(grave)
				deck.shuffle()
				grave.clear()
				grave_updated.emit(grave)
			else:
				print("No cards available to draw.")
				break
		
		var card: CardModel = deck.pop_front()
		hand.append(card)
		deck.erase(card)
	
	hand_updated.emit(hand)
	deck_updated.emit(deck)

func discard_card(model: CardModel) -> void:
	var was_in_hand: bool = hand.has(model)
	if was_in_hand:
		hand.erase(model)
	
	## Insert grave hook here
	grave.append(model)
	
	if was_in_hand:
		hand_updated.emit(hand)
	grave_updated.emit(grave)



func can_pay_costs(costs: Array[CostModel]) -> bool:
	var condition: bool = true
	
	for cost: CostModel in costs:
		match cost.type:
			CostModel.Type.LIMB:
				condition = condition and _can_use_limbs(cost.amount)
			CostModel.Type.MOUTH:
				condition = condition and _can_use_mouth(cost.amount)
			CostModel.Type.DISCARD:
				condition = condition and _can_discard(cost.amount)
			_:
				condition = false
				push_error("Error: Unhandled cost type.")
	
	return condition

func pay_costs(card_model: CardModel, costs: Array[CostModel]) -> bool:
	var condition:= can_pay_costs(costs)
	if condition:
		for cost: CostModel in costs:
			match cost.type:
				CostModel.Type.LIMB:
					use_limbs(cost.amount)
				CostModel.Type.MOUTH:
					use_mouth(cost.amount)
				CostModel.Type.DISCARD:
					await FighterCmd.discard_cards(self, cost.amount, self, card_model)
	
	return condition

func use_limbs(amount: int) -> bool:
	if not _can_use_limbs(amount):
		return false
	
	num_limbs -= amount
	return true

func use_mouth(amount: int) -> bool:
	if not _can_use_mouth(amount):
		return false
	
	num_mouth -= amount
	return true



func _can_use_limbs(amount: int) -> bool:
	return num_limbs >= amount

func _can_use_mouth(amount: int) -> bool:
	return num_mouth >= amount

func _can_discard(amount: int) -> bool:
	return (hand.size()) >= amount














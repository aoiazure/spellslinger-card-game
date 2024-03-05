class_name StatusModel extends RefCounted

enum TickTime {
	LOOP_START, LOOP_END,
	UPKEEP_END, TURN_END,
	TRIGGER,
}

enum Type {
	BUFF, DEBUFF
}

enum Trigger {
	NONE,
	ON_CAST, 
	ON_DAMAGE_TAKEN,
	ON_DAMAGE_DEALT,
}

var title: String
var description: String
var texture: Texture2D

var strength: int = 0
var duration: int = -1
var type: StatusModel.Type = Type.DEBUFF
var tick: TickTime = TickTime.LOOP_END

var can_stack: bool = false
var can_stack_duration: bool = false
var trigger: Trigger = Trigger.NONE

## List of effects

var affects_damage_dealt: bool = false

var affects_damage_taken: bool = false

var affects_cards_drawn: bool = false

var affects_limbs_count: bool = false

var affects_mouth_count: bool = false


static func apply_statuses_to_card(_card_model: CardModel) -> void:
	pass



func affect(_input: Variant) -> Variant:
	return null

func get_description() -> String:
	return description


#region Buffs

class ChannelBuff extends StatusModel:
	func _init(_duration: int, _amount: int) -> void:
		title = "ChannelBuff"
		strength = _amount
		duration = _duration
		tick = TickTime.TURN_END
		type = Type.BUFF
		affects_damage_dealt = true
		
		description = get_description()
	
	func affect(amount):
		return amount + strength
	
	func get_description() -> String:
		return "Increases damage dealt per hit by %s." % strength


class DrawMore extends StatusModel:
	func _init(_duration: int, _amount: int) -> void:
		title = "DrawMore"
		strength = _amount
		duration = _duration
		tick = TickTime.LOOP_START
		type = Type.BUFF
		affects_cards_drawn = true
		
		description = get_description()
	
	func affect(amount):
		return amount + strength
	
	func get_description() -> String:
		return "Draw %s additional cards next turn." % strength


class DrawMoreStartTurn extends StatusModel:
	func _init(_duration: int, _amount: int) -> void:
		title = "DrawMoreStartTurn"
		strength = _amount
		duration = _duration
		tick = TickTime.LOOP_START
		type = Type.BUFF
		affects_cards_drawn = true
		
		can_stack = true
		description = get_description()
	
	func affect(amount):
		return amount + strength
	
	func get_description() -> String:
		return "Draw %s additional cards next turn." % strength


class BlockShield extends StatusModel:
	func _init(_duration: int, _amount: int) -> void:
		title = "BlockShield"
		strength = _amount
		duration = _duration
		tick = TickTime.UPKEEP_END
		type = Type.BUFF
		affects_damage_taken = true
		
		can_stack = true
		description = get_description()
	
	func affect(amount):
		printt(amount, strength)
		var reduction: int = amount - strength
		strength = max(strength - amount, 0)
		return max(reduction, 0)
	
	func get_description() -> String:
		return "Take up to %s less damage until next turn." % strength


class GrowLimb extends StatusModel:
	func _init(_duration: int, _amount: int) -> void:
		title = "GrowLimb"
		strength = _amount
		duration = _duration
		tick = TickTime.LOOP_START
		type = Type.BUFF
		affects_limbs_count = true
		
		can_stack = true
		description = get_description()
	
	func affect(amount):
		return amount + strength
	
	func get_description() -> String:
		return "Gain %s additional limb(s)." % strength


class Toughness extends StatusModel:
	func _init(_duration: int, _amount: int) -> void:
		title = "Toughness"
		strength = _amount
		duration = _duration
		tick = TickTime.UPKEEP_END
		type = Type.BUFF
		affects_damage_taken = true
		
		can_stack = true
		description = get_description()
	
	func affect(amount):
		return maxi(amount - strength, 1) 
	
	func get_description() -> String:
		return "Take %s less damage, to a minimum of 1." % strength



#endregion



#region Debuffs

class Vulnerable extends StatusModel:
	func _init(_duration: int, _amount: int) -> void:
		title = "Exhaustion"
		strength = _amount
		duration = _duration
		tick = TickTime.TURN_END
		type = Type.DEBUFF
		affects_damage_taken = true
		
		can_stack = false
		can_stack_duration = true
		description = get_description()
	
	func affect(amount):
		return amount + ceili(amount * (float(strength) / 10.0))
	
	func get_description() -> String:
		return "Take additional %s%% damage, rounded up." % (strength * 10)

class Weak extends StatusModel:
	func _init(_duration: int, _amount: int) -> void:
		title = "Weakened"
		strength = _amount
		duration = _duration
		tick = TickTime.TURN_END
		type = Type.DEBUFF
		affects_damage_dealt = true
		
		can_stack = false
		can_stack_duration = true
		description = get_description()
	
	func affect(amount):
		return maxi(amount - strength, 0)
	
	func get_description() -> String:
		return "Deal %s less damage." % strength

#endregion








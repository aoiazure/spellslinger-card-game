## Data type to represent a card.
class_name CardModel extends Resource

enum Type {
	ATTACK, 	## Something that deals damage.
	SKILL		## Somethat that does something besides damage.
}



static var Database: Dictionary = {
	# Attacks
	"ThousandCuts": ThousandCuts.new(),
	"Fireball": Fireball.new(),
	"Gutshot": Gutshot.new(),
	"AnkleSlice": AnkleSlice.new(),
	"SmackBlockSmall": SmackBlockSmall.new(),
	"SlashWound": SlashWound.new(),
	"LoudShout": LoudShout.new(),
	"RallyShout": RallyShout.new(),
	"UltimateTechnique": UltimateTechnique.new(),
	# Skills
	"LittleEverything": LittleEverything.new(),
	"BasicDodge": BasicDodge.new(),
	"FaithlessLooting": FaithlessLooting.new(),
	"FiendishBargain": FiendishBargain.new(),
	"OneForTwo": OneForTwo.new(),
	"DrawMoreNext": DrawMoreNext.new(),
	"GrowLimb": GrowLimb.new(),
	"MouthBlockDraw": MouthBlockDraw.new(),
}



## Name of the card.
@export var title: String = ""
## The verbal description of the card.
@export_multiline var description: String = ""
## What you need to spend to play the card.
@export var costs: Array[CostModel] = []
## What type of card it is.
@export var type: Type = Type.SKILL

@export_group("Requirements", "requires")
## Requires a mouth able to speak to cast the spell.
@export var requires_verbal: bool = false
## Requires limbs able to move to cast the spell.
@export var requires_somatic: bool = false

@export_group("Targets", "targets")
## Whether it targets an enemy.
@export var targets_enemy: bool = false
## Whether it targets yourself.
@export var targets_self: bool = false

@export_group("Stats")
@export var damage: int = 0

func _to_string() -> String:
	return title

func play(owner: ClashState, _target: ClashState) -> void:
	await owner.get_tree().create_timer(0.0).timeout



#region Attacks

class ThousandCuts extends CardModel:
	func _init() -> void:
		damage = 3
		title = "Thousand Cuts"
		description = "Deal %s damage. Add a copy to your deck." % damage
		
		type = Type.ATTACK
		costs = [CostModel.create(CostModel.Type.LIMB, 0)]
		
		targets_enemy = true
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.damage(target, damage, owner, self)
		(owner as PlayerClashState).deck.append(ThousandCuts.new())
		(owner as PlayerClashState).deck_updated.emit(owner.deck)


class Fireball extends CardModel:
	func _init() -> void:
		damage = 5
		title = "Fireball"
		description = "Deal %s damage." % damage
		
		type = Type.ATTACK
		costs = [CostModel.create(CostModel.Type.LIMB, 1)]
		
		targets_enemy = true
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.damage(target, damage, owner, self)


class Gutshot extends CardModel:
	func _init() -> void:
		damage = 3
		title = "Twinflame"
		description = "Deal %sx2 damage." % [damage]
		
		type = Type.ATTACK
		costs = [CostModel.create(CostModel.Type.LIMB, 1)]
		
		targets_enemy = true
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.damage(target, damage, owner, self)
		await FighterCmd.damage(target, damage, owner, self)


class AnkleSlice extends CardModel:
	func _init() -> void:
		damage = 3
		title = "Soulcutter"
		description = "Deal %s damage. Apply 1 Exhaustion until end of next turn." % [damage]
		
		type = Type.ATTACK
		costs = [CostModel.create(CostModel.Type.LIMB, 1)]
		
		targets_enemy = true
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.damage(target, damage, owner, self)
		await FighterCmd.apply_status(target, StatusModel.Vulnerable.new(2, 1), owner, self)


class SmackBlockSmall extends CardModel:
	var block_amount: int = 4
	
	func _init() -> void:
		damage = 4
		title = "Reversal"
		description = "Deal %s damage. Dodge %s." % [damage, block_amount]
		
		type = Type.ATTACK
		costs = [CostModel.create(CostModel.Type.LIMB, 2)]
		
		targets_enemy = true
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.damage(target, damage, owner, self)
		await FighterCmd.apply_status(owner, StatusModel.BlockShield.new(1, block_amount), owner, self)


class SlashWound extends CardModel:
	func _init() -> void:
		damage = 7
		title = "Reversal"
		description = "Deal %s damage. Apply 2 Exhaustion until end of next round." % [damage]
		
		type = Type.ATTACK
		costs = [CostModel.create(CostModel.Type.LIMB, 2)]
		
		targets_enemy = true
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.damage(target, damage, owner, self)
		await FighterCmd.apply_status(owner, StatusModel.Vulnerable.new(2, 2), owner, self)


class LoudShout extends CardModel:
	func _init() -> void:
		damage = 8
		title = "Vociferate"
		description = "Deal %s damage. Draw 1." % [damage]
		
		type = Type.ATTACK
		costs = [CostModel.create(CostModel.Type.MOUTH, 1)]
		
		targets_enemy = true
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.damage(target, damage, owner, self)
		await FighterCmd.draw_cards(owner, 1, owner, self)


class RallyShout extends CardModel:
	func _init() -> void:
		damage = 6
		title = "Rallying Cry"
		description = "Deal %s damage. Channel 1 until end of turn." % [damage]
		
		type = Type.ATTACK
		costs = [CostModel.create(CostModel.Type.MOUTH, 1)]
		
		targets_enemy = true
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.damage(target, damage, owner, self)
		await FighterCmd.apply_status(owner, StatusModel.ChannelBuff.new(1, 1), owner, self)


class UltimateTechnique extends CardModel:
	func _init() -> void:
		damage = 10
		title = "Ultimate Technique"
		description = "Gain 1 limb until end of combat. Deal %s damage. Channel 2 until end of next turn." % [damage]
		
		type = Type.ATTACK
		costs = [
			CostModel.create(CostModel.Type.LIMB, 2),
			CostModel.create(CostModel.Type.MOUTH, 1),
			CostModel.create(CostModel.Type.DISCARD, 1)
		]
		
		targets_enemy = true
	
	func play(owner: ClashState, target: ClashState) -> void:
		var status:= StatusModel.GrowLimb.new(-1, 1)
		await FighterCmd.apply_status(target, status, owner, self)
		await FighterCmd.damage(target, damage, owner, self)
		await FighterCmd.apply_status(owner, StatusModel.ChannelBuff.new(2, 2), owner, self)



#endregion


#region Skills


class LittleEverything extends CardModel:
	func _init() -> void:
		title = "Refreshing Breath"
		description = "Draw 1. Channel 1 until end of turn. Dodge 2."
		targets_self = true
		
		type = Type.SKILL
		costs = []
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.draw_cards(owner, 1, owner, self)
		await FighterCmd.apply_status(owner, StatusModel.ChannelBuff.new(1, 1), owner, self)
		await FighterCmd.apply_status(target, StatusModel.BlockShield.new(1, 2), owner, self)


class BasicDodge extends CardModel:
	func _init() -> void:
		title = "Dodge"
		description = "Dodge 7."
		
		type = Type.SKILL
		costs = [CostModel.create(CostModel.Type.LIMB, 1)]
		
		targets_enemy = false
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.apply_status(target, StatusModel.BlockShield.new(1, 7), owner, self)


class FaithlessLooting extends CardModel:
	func _init() -> void:
		title = "Adrenaline Rush"
		description = "Draw 2 cards. Discard 2 cards."
		
		type = Type.SKILL
		costs = [CostModel.create(CostModel.Type.LIMB, 1)]
		
		targets_enemy = false
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.draw_cards(target, 2, owner, self)
		await FighterCmd.discard_cards(target, 2, owner, self)


class FiendishBargain extends CardModel:
	func _init() -> void:
		title = "Fiendish Bargain"
		description = "Add 1 card from your deck to your hand."
		
		type = Type.SKILL
		costs = [
			CostModel.create(CostModel.Type.LIMB, 1),
			CostModel.create(CostModel.Type.MOUTH, 1)
		]
		
		targets_enemy = false
	
	func play(owner: ClashState, target: ClashState) -> void:
		var cards:= await FighterCmd.select_cards_in_zone(target, 1, ZoneViewer.Zones.DECK, owner, self)
		if cards.is_empty():
			return
		
		var card: CardModel = cards.pop_front()
		target.deck.erase(card)
		target.hand.append(card)
		target.hand_updated.emit(target.hand)
		target.deck_updated.emit(target.deck)


class OneForTwo extends CardModel:
	func _init() -> void:
		title = "Abandon Self"
		description = "To play, discard 1 card.\n\nDraw 2 cards."
		
		type = Type.SKILL
		costs = [
			CostModel.create(CostModel.Type.MOUTH, 1),
			CostModel.create(CostModel.Type.DISCARD, 1),
		]
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.draw_cards(target, 2, owner, self)


class DrawMoreNext extends CardModel:
	func _init() -> void:
		title = "Prep Time"
		description = "Draw 2 cards at the start of your next turn."
		
		type = Type.SKILL
		costs = [CostModel.create(CostModel.Type.LIMB, 1)]
		
		targets_enemy = false
	
	func play(owner: ClashState, target: ClashState) -> void:
		var status:= StatusModel.DrawMoreStartTurn.new(1, 2)
		await FighterCmd.apply_status(target, status, owner, self)


class GrowLimb extends CardModel:
	func _init() -> void:
		title = "Grow Limb"
		description = "Grow an additional limb until end of combat."
		
		type = Type.SKILL
		costs = [CostModel.create(CostModel.Type.LIMB, 2), CostModel.create(CostModel.Type.MOUTH, 1)]
		
		targets_enemy = false
	
	func play(owner: ClashState, target: ClashState) -> void:
		var status:= StatusModel.GrowLimb.new(-1, 1)
		await FighterCmd.apply_status(target, status, owner, self)


class MouthBlockDraw extends CardModel:
	func _init() -> void:
		title = "Backup Plan"
		description = "Dodge 5. Draw 1."
		
		type = Type.SKILL
		costs = [CostModel.create(CostModel.Type.MOUTH, 1)]
		
		targets_enemy = false
	
	func play(owner: ClashState, target: ClashState) -> void:
		await FighterCmd.apply_status(target, StatusModel.BlockShield.new(1, 5), owner, self)
		await FighterCmd.draw_cards(target, 1, owner, self)



#endregion
















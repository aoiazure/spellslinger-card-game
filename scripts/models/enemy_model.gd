## Data type that represents an enemy.
class_name EnemyModel extends CharacterModel


static var Commons: Array[EnemyModel] = [
	Goblin.new(), Imp.new(), Kobold.new(), Skeleton.new(), Zombie.new()
]

static var Elites: Array[EnemyModel] = [
	Drake.new(), Hydra.new()
]


var texture: Texture2D
var actions: Array[ActionModel] = []

func decide_action(_turn_number: int) -> ActionModel:
	var action: ActionModel = actions.pick_random()
	print("%s" % [action.description])
	return action


#region Common Enemies

class Goblin extends EnemyModel:
	func _init() -> void:
		title = "Goblin"
		max_hp = 20
		cur_hp = max_hp
		
		texture = preload("res://images/enemies/goblin.png")
		
		actions = [
			ActionModel.create(
				"Planning on stabbing you.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 5, enemy, null) \
			),
			ActionModel.create(
				"Planning on punching you twice.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 3, enemy, null)
					await FighterCmd.damage(player, 3, enemy, null) \
			),
			ActionModel.create(
				"Planning to grow a little angrier.",
				func(enemy: EnemyClashState, _player: PlayerClashState):
					await FighterCmd.apply_status(enemy, StatusModel.ChannelBuff.new(999, 2), enemy, null) \
			),
			ActionModel.create(
				"Planning on blocking.",
				func(enemy: EnemyClashState, _player: PlayerClashState):
					await FighterCmd.apply_status(enemy, StatusModel.BlockShield.new(1, 3), enemy, null) \
			),
		]

class Imp extends EnemyModel:
	func _init() -> void:
		title = "Imp"
		max_hp = 25
		cur_hp = max_hp
		
		texture = preload("res://images/enemies/imp.png")
		
		actions = [
			ActionModel.create(
				"Planning on debuffing your spells.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.apply_status(player, StatusModel.Weak.new(1, 1), enemy, null) \
			),
			ActionModel.create(
				"Planning on clawing you twice.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 4, enemy, null)
					await FighterCmd.damage(player, 4, enemy, null) \
			),
			ActionModel.create(
				"Planning to claw and dodge.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 4, enemy, null)
					await FighterCmd.apply_status(enemy, StatusModel.ChannelBuff.new(999, 1), enemy, null) \
			),
		]

class Kobold extends EnemyModel:
	func _init() -> void:
		title = "Kobold"
		max_hp = 22
		cur_hp = max_hp
		
		texture = preload("res://images/enemies/kobold.png")
		
		actions = [
			ActionModel.create(
				"Planning on dodging.",
				func(enemy: EnemyClashState, _player: PlayerClashState):
					await FighterCmd.apply_status(enemy, StatusModel.BlockShield.new(1, 5), enemy, null) \
			),
			ActionModel.create(
				"Planning on slashing you.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 4, enemy, null) \
			),
			ActionModel.create(
				"Planning to scratch three to five times.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					var amount:= randi_range(0, 3)
					for i in range(3+amount):
						await FighterCmd.damage(player, 1, enemy, null) \
			),
			ActionModel.create(
				"Planning on debuffing your spells significantly.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.apply_status(player, StatusModel.Weak.new(1, 3), enemy, null) \
			),
		]


class Skeleton extends EnemyModel:
	func _init() -> void:
		title = "Skeleton"
		max_hp = 24
		cur_hp = max_hp
		
		texture = preload("res://images/enemies/skeleton.png")
		
		actions = [
			ActionModel.create(
				"Planning on clubbing you.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					#await FighterCmd.apply_status(enemy, StatusModel.BlockShield.new(1, 5), enemy, null)
					await FighterCmd.damage(player, 4, enemy, null) \
			),
			ActionModel.create(
				"Planning on reassembling its bones.",
				func(enemy: EnemyClashState, _player: PlayerClashState):
					await FighterCmd.gain_hp(enemy, 5, enemy, null) \
			),
			ActionModel.create(
				"Planning on striking and rolling away.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 3, enemy, null)
					await FighterCmd.block(enemy, 1, 3, null) \
			),
		]


class Zombie extends EnemyModel:
	func _init() -> void:
		title = "Zombie"
		max_hp = 24
		cur_hp = max_hp
		
		texture = preload("res://images/enemies/zombie.png")
		
		actions = [
			ActionModel.create(
				"Planning on biting and consuming your vigor.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 3, enemy, null)
					await FighterCmd.apply_status(enemy, StatusModel.ChannelBuff.new(-1, 1), enemy, null) \
			),
			ActionModel.create(
				"Planning on growing much stronger.",
				func(enemy: EnemyClashState, _player: PlayerClashState):
					await FighterCmd.apply_status(enemy, StatusModel.ChannelBuff.new(-1, 2), enemy, null) \
			),
			ActionModel.create(
				"Planning on swinging twice and exposing you.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 2, enemy, null)
					await FighterCmd.damage(player, 2, enemy, null)
					await FighterCmd.apply_status(player, StatusModel.Vulnerable.new(-1, 1), enemy, null) \
			),
		]



#endregion

#region Elite enemies

class Drake extends EnemyModel:
	func _init() -> void:
		title = "Drake"
		max_hp = 50
		cur_hp = max_hp
		starting_statuses = [StatusModel.Toughness.new(-1, 1)]
		
		texture = preload("res://images/enemies/drake.png")
		
		actions = [
			ActionModel.create(
				"Planning on slashing you with two claws.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 5, enemy, null)
					await FighterCmd.damage(player, 5, enemy, null) \
			),
			ActionModel.create(
				"Planning on flying out of reach.",
				func(enemy: EnemyClashState, _player: PlayerClashState):
					await FighterCmd.apply_status(enemy, StatusModel.BlockShield.new(1, 10), enemy, null) \
			),
			ActionModel.create(
				"Planning to strike a critical point, hampering you.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 5, enemy, null)
					await FighterCmd.apply_status(player, StatusModel.Vulnerable.new(-1, 1), enemy, null) \
			),
			ActionModel.create(
				"Planning to strike a critical point, exposing you for a time.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 7, enemy, null)
					await FighterCmd.apply_status(player, StatusModel.Weak.new(2, 1), enemy, null) \
			),
		]


class Hydra extends EnemyModel:
	class HydraHead extends StatusModel:
		func _init(_duration: int, _amount: int) -> void:
			title = "HydraHead"
			strength = _amount
			duration = _duration
			tick = TickTime.UPKEEP_END
			type = Type.BUFF
			
			can_stack = true
			description = get_description()
		
		func get_description() -> String:
			return "The Hydra has %s heads. Effects scale based on heads." % strength
	
	func _get_head_count(enemy_state: EnemyClashState) -> int:
		var status: StatusModel = enemy_state.statuses.filter(func(s): return s.title == "HydraHead").front()
		return status.strength
	
	func _init() -> void:
		title = "Hydra"
		max_hp = 40
		cur_hp = max_hp
		starting_statuses = [HydraHead.new(-1, 2)]
		
		texture = preload("res://images/enemies/hydra.png")
		
		actions = [
			ActionModel.create(
				"Planning on biting with each of its heads.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					for i in _get_head_count(enemy):
						await FighterCmd.damage(player, 2, enemy, null) \
			),
			ActionModel.create(
				"Planning on rampaging recklessly and sprouting a head.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, 5, enemy, null)
					await FighterCmd.damage(enemy, 3, enemy, null)
					await FighterCmd.apply_status(enemy, HydraHead.new(-1, 1), enemy, null) \
			),
			ActionModel.create(
				"Planning on blocking with each of its heads and striking all at once.",
				func(enemy: EnemyClashState, player: PlayerClashState):
					await FighterCmd.damage(player, _get_head_count(enemy), enemy, null)
					await FighterCmd.apply_status(
						player, StatusModel.BlockShield.new(1, _get_head_count(enemy)), 
						enemy, null) \
			),
			ActionModel.create(
				"Planning on growing two heads.",
				func(enemy: EnemyClashState, _player: PlayerClashState):
					await FighterCmd.apply_status(enemy, HydraHead.new(-1, 2), enemy, null) \
			),
		]



#endregion







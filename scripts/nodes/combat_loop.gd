class_name CombatLoop extends Node

enum EnemyType {
	COMMON,
	ELITE,
	BOSS
}

enum Result {
	VICTORY,
	LOSS
}

#region signals
signal combat_started
signal combat_ended(result, turn_number, enemy_name)

signal do_loop
signal loop_started(number)
signal loop_ended(number)

signal player_turn_started
signal player_upkeep_ended
signal player_turn_ended

## Emitted when the enemy is chosen for the combat encounter.
signal enemy_selected(enemy_model)
## Emitted when the enemy chose its action.
signal enemy_action_decided(action)

signal enemy_turn_started
signal enemy_upkeep_ended
signal enemy_turn_ended

## Data
signal hand_updated(hand)
signal deck_updated(deck)
signal grave_updated(grave)

signal limbs_updated(cur, max)
signal mouth_updated(cur, max)

signal player_hp_changed(current, maximum)
signal enemy_hp_changed(current, maximum)

signal player_statuses_changed(statuses)
signal enemy_statuses_changed(statuses)

#endregion

### Per combat
var player_model: PlayerModel
var enemy_model: EnemyModel

var player_state: PlayerClashState
var enemy_state: EnemyClashState

var is_combat_over: bool = false
var is_player_turn: bool = false

var turn_number: int = 1



func _ready() -> void:
	do_loop.connect(_loop)
	loop_started.connect(_on_loop_started)
	loop_ended.connect(_on_loop_ended)

func _on_game_loop_combat_start(room_number: int, player: CharacterModel) -> void:
	player_model = player
	start_combat(room_number, player)

func start_combat(room_number: int, _player_model: CharacterModel) -> void:
	## Player
	player_state = PlayerClashState.create(
		_player_model.cur_hp, _player_model.max_hp, 
		_player_model.deck, _player_model.starting_statuses
	)
	%ClashStates.add_child(player_state)
	
	player_state.hand_updated.connect(_on_player_state_hand_updated)
	player_state.deck_updated.connect(_on_player_state_deck_updated)
	player_state.grave_updated.connect(_on_player_state_grave_updated)
	
	player_state.limbs_updated.connect(_on_player_state_limbs_updated)
	player_state.mouth_updated.connect(_on_player_state_mouth_updated)
	
	player_state.statuses_changed.connect(_on_player_state_statuses_changed)
	_on_player_state_statuses_changed(player_state.statuses)
	
	player_state.hp_changed.connect(_on_player_state_hp_changed)
	_on_player_state_hp_changed(player_state.cur_hp, player_state.max_hp)
	
	## Enemy
	#if room_number % 5 == 0:
	if room_number % 3 == 0:
		enemy_model = _get_random_enemy(EnemyType.ELITE)
		#enemy_model = _get_random_enemy(EnemyType.BOSS)
	#elif room_number % 3 == 0:
		#enemy_model = _get_random_enemy(EnemyType.ELITE)
	else:
		enemy_model = _get_random_enemy(EnemyType.COMMON)
	
	enemy_state = EnemyClashState.create(enemy_model.cur_hp, enemy_model.max_hp, enemy_model.starting_statuses)
	%CharacterModels.add_child(enemy_model)
	%ClashStates.add_child(enemy_state)
	
	enemy_selected.emit(enemy_model)
	
	enemy_state.hp_changed.connect(_on_enemy_state_hp_changed)
	enemy_state.statuses_changed.connect(_on_enemy_state_statuses_changed)
	
	# Start
	combat_started.emit()
	# Start loop
	do_loop.emit()



func _loop() -> void:
	while true:
		# Start loop
		loop_started.emit(turn_number)
		# Enemy decides turn
		var action_model: ActionModel = enemy_model.decide_action(turn_number)
		enemy_action_decided.emit(action_model)
		# Player
		await _player_turn()
		# Check end combat
		if check_combat_over():
			end_combat()
			return
		# Enemy
		await _enemy_turn(action_model)
		# Check end combat
		if check_combat_over():
			end_combat()
			return
		# End loop
		loop_ended.emit(turn_number)



func _player_turn() -> void:
	player_state.start_upkeep()
	player_upkeep_ended.emit()
	player_state.tick_statuses(StatusModel.TickTime.UPKEEP_END)
	
	player_turn_started.emit()
	is_player_turn = true
	
	await player_turn_ended
	is_player_turn = false
	print("%s took its turn.\n" % player_model.title)
	player_state.tick_statuses(StatusModel.TickTime.TURN_END)

func _enemy_turn(action_model: ActionModel) -> void:
	enemy_upkeep_ended.emit()
	enemy_state.tick_statuses(StatusModel.TickTime.UPKEEP_END)
	enemy_turn_started.emit()
	
	await action_model.action.call(enemy_state, player_state)
	print("%s took its turn.\n" % enemy_model.title)
	enemy_state.tick_statuses(StatusModel.TickTime.TURN_END)
	enemy_turn_ended.emit()





func _on_loop_started(_number: int) -> void:
	print("= Turn %s started =" % turn_number)

func _on_loop_ended(_number: int) -> void:
	print("= Turn %s ended =\n" % turn_number)
	turn_number += 1



func end_combat() ->  void:
	is_combat_over = true
	loop_ended.emit(turn_number)
	
	var msg: String
	var res: Result
	if enemy_state.cur_hp <= 0:
		msg = ("Player victory")
		res = Result.VICTORY
	elif player_state.cur_hp <= 0:
		msg = ("Player lost")
		res = Result.LOSS
	
	var _turn:= turn_number
	var _enemy_name:= enemy_model.title
	
	## Player
	# Propogate damage to outside
	player_model.cur_hp = player_state.cur_hp
	player_model.max_hp = player_state.max_hp
	
	player_state.statuses.clear()
	player_state.queue_free()
	player_model = null
	player_state = null
	## Enemy
	enemy_state.statuses.clear()
	enemy_model.queue_free()
	enemy_state.queue_free()
	enemy_model = null
	enemy_state = null
	
	## Reset stats
	turn_number = 1
	is_player_turn = false
	is_combat_over = false
	
	print("Combat ended.")
	print(msg, "\n")
	combat_ended.emit(res, _turn, _enemy_name)



func check_combat_over() -> bool:
	if is_combat_over:
		return true
	
	var condition:= enemy_state.cur_hp <= 0 or player_state.cur_hp <= 0
	
	return condition


#region Helpers


func _get_random_enemy(type: EnemyType = EnemyType.COMMON) -> EnemyModel:
	match type:
		EnemyType.COMMON:
			return (EnemyModel.Commons.pick_random() as EnemyModel).duplicate()
		EnemyType.ELITE:
			return (EnemyModel.Elites.pick_random() as EnemyModel).duplicate()
	
	# Default to a goblin otherwise
	return EnemyModel.Goblin.new()


#endregion



#region Signals

func _on_combat_ui_card_selected(card_view: CardView) -> void:
	if is_player_turn:
		var model: CardModel = card_view.model
		# Remove card from hand
		player_state.hand.erase(model)
		player_state.hand_updated.emit(player_state.hand)
		if not player_state.can_pay_costs(model.costs):
			print("Cannot pay for %s." % model.title)
			player_state.hand.append(model)
			player_state.hand_updated.emit(player_state.hand)
			return
		
		# Pay costs
		await player_state.pay_costs(model, model.costs)
		# Choose targets
		@warning_ignore("incompatible_ternary")
		var target: ClashState = enemy_state if model.targets_enemy else player_state
		
		# Trigger on cast
		
		player_state.tick_triggers(StatusModel.Trigger.ON_CAST)
		# Cast
		await model.play(player_state, target)
		# Put card in grave
		player_state.discard_card(model)
		# Tell you it was done (TEMPORARY)
		print("%s was played." % model.title)
		
		is_combat_over = check_combat_over()
		if is_combat_over:
			player_turn_ended.emit()

func _on_combat_ui_request_end_turn() -> void:
	if is_player_turn:
		player_turn_ended.emit()



func _on_player_state_hand_updated(hand: Array[CardModel]) -> void:
	hand_updated.emit(hand)

func _on_player_state_deck_updated(deck: Array[CardModel]) -> void:
	deck_updated.emit(deck)

func _on_player_state_grave_updated(grave: Array[CardModel]) -> void:
	grave_updated.emit(grave)

func _on_player_state_limbs_updated(_cur: int, _max: int) -> void:
	limbs_updated.emit(_cur, _max)

func _on_player_state_mouth_updated(_cur: int, _max: int) -> void:
	mouth_updated.emit(_cur, _max)

func _on_player_state_hp_changed(current: int, maximum: int) -> void:
	print("%s HP: %s/%s" % [player_model.title, current, maximum])
	player_hp_changed.emit(current, maximum)

func _on_player_state_statuses_changed(statuses: Array[StatusModel]) -> void:
	player_statuses_changed.emit(statuses)



func _on_enemy_state_hp_changed(current: int, maximum: int) -> void:
	print("%s HP: %s/%s" % [enemy_model.title, current, maximum])
	enemy_hp_changed.emit(current, maximum)

func _on_enemy_state_statuses_changed(statuses: Array[StatusModel]) -> void:
	enemy_statuses_changed.emit(statuses)

#endregion













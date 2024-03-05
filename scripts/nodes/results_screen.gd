class_name ResultsScreen extends Control

signal continue_requested
signal return_requested

@export_group("References")
@export var zone_viewer: ZoneViewer
@export var cards_button: Button
@export var deck: DeckView

@export_subgroup("Victory")
@export var victory_screen: CenterContainer

@export_subgroup("Loss")
@export var loss_screen: CenterContainer
@export var label_loss_details: Label



var _player: PlayerModel :
	set(val):
		_player = val
		deck.deck = _player.deck

var _rewards: Array[CardModel]



func generate_card_rewards() -> Array[CardModel]:
	var rewards: Array[CardModel] = []
	
	var pick_amount: int = 3
	var card_names: Array = CardModel.Database.keys()
	
	var picks: Array[String] = []
	
	while rewards.size() < pick_amount:
		var pick: String = card_names.pick_random()
		if not picks.has(pick):
			picks.append(pick)
			rewards.append((CardModel.Database[pick] as CardModel).duplicate())
	
	return rewards


func _on_combat_loop_combat_ended(res: CombatLoop.Result, _turn_number: int, enemy_name: String) -> void:
	self.show()
	
	if res == CombatLoop.Result.VICTORY:
		victory_screen.show()
		loss_screen.hide()
		cards_button.show()
	else:
		victory_screen.hide()
		loss_screen.show()
		label_loss_details.text = "You died to %s at room %s." % [enemy_name, %GameLoop.room_number]


func _on_cards_button_pressed() -> void:
	_rewards = generate_card_rewards()
	zone_viewer.set_up(_rewards)
	var pick: Array[CardModel] = await zone_viewer.select_cards(1)
	_player.deck.append(pick.pop_front())
	cards_button.hide()


func _on_continue_button_pressed() -> void:
	continue_requested.emit()
	self.hide()


func _on_back_button_pressed() -> void:
	return_requested.emit()
	self.hide()


func _on_game_loop_player_created(player: PlayerModel) -> void:
	_player = player











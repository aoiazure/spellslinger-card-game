class_name GameLoop extends Node

signal player_created(player)
signal combat_start(room_number, player)



var player: CharacterModel
var room_number: int = 1


func start_game(model: PlayerModel) -> void:
	player = model.duplicate()
	player.name = "Player%s" % player.title
	%CharacterModels.add_child(player)
	
	room_number = 1
	player_created.emit(player)
	combat_start.emit(room_number, player)


func _on_combat_loop_combat_ended(res: CombatLoop.Result, _turn_number: int, _enemy_name: String) -> void:
	if res == CombatLoop.Result.VICTORY:
		room_number += 1


func _on_results_screen_continue_requested() -> void:
	combat_start.emit(room_number, player)














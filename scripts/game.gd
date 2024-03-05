class_name Game extends Node



@export_group("References")
@export var main_menu: MainMenu
@export var game_loop: GameLoop
@export var results_screen: ResultsScreen
@export var zone_viewer: ZoneViewer
@export_subgroup("Combat")
@export var combat_loop: CombatLoop
@export var combat_ui: CombatUI
@export var models_holder: Node
@export var states_holder: Node





func _on_main_menu_game_start_requested(model: PlayerModel) -> void:
	game_loop.start_game(model)













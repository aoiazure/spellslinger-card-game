class_name MainMenu extends Control

signal game_start_requested(character)



@export_group("References")
@export var container_main: CenterContainer
@export var container_class_select: CenterContainer
@export var container_select_box: VBoxContainer


@onready var scene_character_select:= preload("res://scenes/character_select_node.tscn")



func _ready() -> void:
	container_main.show()
	container_class_select.hide()
	
	for title in PlayerModel.Playables.keys():
		var select:= scene_character_select.instantiate() as CharacterSelect
		select.player_model = (PlayerModel.Playables[title] as PlayerModel).duplicate()
		container_class_select.add_child(select)
		select.character_selected.connect(_on_character_select_character_selected)


func _on_results_screen_return_requested() -> void:
	self.show()


#region MAIN MENU
func _on_start_button_pressed() -> void:
	container_main.hide()
	container_class_select.show()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

#endregion



func _on_character_select_character_selected(character_model: PlayerModel) -> void:
	game_start_requested.emit(character_model)
	self.hide()


















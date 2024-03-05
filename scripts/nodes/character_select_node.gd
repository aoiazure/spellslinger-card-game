class_name CharacterSelect extends Control

signal character_selected(character_model)
signal deck_preview_requested(deck)

@export var button_character: Button
@export var button_preview: Button


var player_model: PlayerModel :
	set(val):
		player_model = val
		button_character.text = player_model.title



func _on_character_button_pressed() -> void:
	character_selected.emit(player_model)

func _on_preview_deck_button_pressed() -> void:
	var zone_viewer: ZoneViewer = get_tree().get_first_node_in_group("zone_viewer") as ZoneViewer
	zone_viewer.set_up(player_model.deck)
	zone_viewer.view("Viewing Starter Deck of %s" % player_model.title, false)






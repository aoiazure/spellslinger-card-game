class_name DeckView extends PanelContainer

@export var label_count: Label

var deck: Array[CardModel] = []



func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).double_click:
			var zone_viewer:= get_tree().get_first_node_in_group("zone_viewer") as ZoneViewer
			zone_viewer.set_up(deck)
			zone_viewer.view("Viewing Deck")
		else:
			pass












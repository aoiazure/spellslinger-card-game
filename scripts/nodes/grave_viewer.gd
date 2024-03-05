class_name GraveView extends Button

var grave: Array[CardModel] = []

func _ready() -> void:
	self.pressed.connect(
		func():
			var zone_viewer:= get_tree().get_first_node_in_group("zone_viewer") as ZoneViewer
			zone_viewer.set_up(grave)
			zone_viewer.view("Viewing Grave")
	)






class_name StatusIcon extends MarginContainer

@export var sprite: TextureRect
@export var label_duration: Label

var status: StatusModel : set = _set_status



func _set_status(val: StatusModel) -> void:
	status = val
	if status.texture:
		sprite.texture = status.texture
	if status.duration > 0:
		label_duration.text = str(status.duration)
	else:
		label_duration.hide()
	
	tooltip_text = status.get_description()











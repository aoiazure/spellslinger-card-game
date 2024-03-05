class_name CardView extends Control

signal card_selected(this)
signal card_hovered(this)
signal card_dehovered(this)

@export_group("References")
@export var sprite: NinePatchRect
@export var label_title: Label
@export var label_cost: Label
@export var label_rules_text: Label

@export_group("Backings", "texture")
@export var texture_normal: Texture2D
@export var texture_hover: Texture2D
@export var texture_select: Texture2D


var model: CardModel : set = _set_model
var is_selected: bool = false :
	set(val):
		is_selected = val
		if is_selected:
			sprite.texture = texture_select 


func _set_model(value: CardModel) -> void:
	model = value
	label_title.text = model.title
	if model.costs.size() > 1:
		var t: String = ""
		for i in range(model.costs.size()):
			t += "%s" % model.costs[i].to_string()
			if i < (model.costs.size() - 1):
				t += ", "
		label_cost.text = t
	elif model.costs.size() == 1:
		label_cost.text = model.costs[0].to_string()
	else:
		label_cost.text = "Free"
	
	label_rules_text.text = "%s" % [model.description]



## 
func _on_body_mouse_entered() -> void:
	card_hovered.emit(self)
	sprite.texture = texture_select if is_selected else texture_hover
## 
func _on_body_mouse_exited() -> void:
	card_dehovered.emit(self)
	sprite.texture = texture_select if is_selected else texture_normal



func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).double_click:
			card_selected.emit(self)
		else:
			pass













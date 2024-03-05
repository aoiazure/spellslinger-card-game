class_name ZoneViewer extends Control

enum Zones {
	HAND,
	DECK,
	GRAVE
}

signal card_selected(card_view)

@export_group("References")
@export var label_view: Label
@export var grid_container: GridContainer
@export var button_finish: Button
@export var button_toggle: Button



@onready var scene_card_view: PackedScene = preload("res://scenes/card_view.tscn")



var _selected_card_views: Array[CardView] = []
var _selected_cards: Array[CardModel] = []
var data: Array[CardModel] = []

var _can_select: bool = false
var _desired_amount: int = 0


func set_up(zone_data: Array[CardModel]) -> void:
	## Reset all data
	data = zone_data
	_selected_card_views.clear()
	_selected_cards.clear()
	_can_select = false
	_desired_amount = 0
	
	for c in grid_container.get_children():
		c.queue_free()
	
	for card: CardModel in data:
		_add_card_to_grid(card)

func view(_text: String = "", show_toggle: bool = true) -> void:
	label_view.text = _text
	button_finish.text = "Close"
	
	button_toggle.visible = show_toggle
	self.show()
	await button_finish.pressed
	self.hide()
	set_up([])

func select_cards(amount: int = 1) -> Array[CardModel]:
	label_view.text = "Select %s Card(s)" % amount
	button_finish.text = "Select %s" % amount
	_can_select = true
	button_finish.disabled = true
	_desired_amount = amount
	self.show()
	
	await button_finish.pressed
	
	self.hide()
	_can_select = false
	_desired_amount = 0
	button_finish.disabled = false
	
	for card_view in _selected_card_views:
		_selected_cards.append(card_view.model)
	
	print(_selected_cards)
	return _selected_cards


func _update_finish_button() -> void:
	button_finish.disabled = not (_selected_card_views.size() == _desired_amount)


func _on_toggle_button_toggled(toggled_on: bool) -> void:
	$MarginContainer.visible = toggled_on
	button_toggle.text = "Hide" if toggled_on else "Show"


func _add_card_to_grid(card: CardModel) -> CardView:
	var card_view:= scene_card_view.instantiate() as CardView
	grid_container.add_child(card_view)
	
	card_view.model = card
	card_view.card_selected.connect(_on_card_selected)
	
	return card_view


func _on_card_selected(card_view: CardView) -> void:
	if not _can_select:
		return
	
	if not _selected_card_views.has(card_view):
		_selected_card_views.append(card_view)
		_update_finish_button()
		card_selected.emit(card_view)
		card_view.is_selected = true
		print("%s selected in zone, selected=%s" % [card_view.model.title, _selected_card_views])
	else:
		_selected_card_views.erase(card_view)
		card_view.is_selected = false












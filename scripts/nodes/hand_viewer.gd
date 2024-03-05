class_name HandView extends ScrollContainer

signal card_selected(card_view)

@export var container: HBoxContainer

@onready var scene_card_view: PackedScene = preload("res://scenes/card_view.tscn")



func add_card_to_hand(card: CardModel) -> CardView:
	var view:= scene_card_view.instantiate() as CardView
	container.add_child(view)
	
	view.model = card
	view.card_selected.connect(_on_card_selected)
	
	return view



func _on_card_selected(card: CardView) -> void:
	card_selected.emit(card)

## On a hand update
func update_hand(hand: Array[CardModel]) -> void:
	for c in container.get_children():
		c.queue_free()
	
	hand.sort_custom(
		func(a: CardModel, b: CardModel):
			if a.title < b.title:
				return false
	)
	
	for card: CardModel in hand:
		add_card_to_hand(card)





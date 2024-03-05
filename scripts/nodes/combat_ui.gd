class_name CombatUI extends Control

signal card_selected(card_view)

signal request_end_turn

@export_group("References")
@export var hand_view: HandView
@export var deck_view: DeckView
@export var grave_view: GraveView

@export_subgroup("Labels", "label")
@export var label_hp: Label
@export var label_limbs: Label
@export var label_mouth: Label
@export var label_turn: Label

@export_subgroup("Enemy")
@export var label_enemy_name: Label
@export var label_enemy_plan: Label
@export var label_enemy_hp: Label
@export var bar_enemy_hp: ProgressBar
@export var sprite_enemy: TextureRect
@export var container_enemy_status: HFlowContainer


@onready var scene_status_icon:= preload("res://scenes/status_icon.tscn")


func _on_end_turn_button_pressed() -> void:
	request_end_turn.emit()


func _on_hand_view_card_selected(card_view: CardView) -> void:
	card_selected.emit(card_view)



#region Player Data
func _on_combat_loop_hand_updated(hand: Array[CardModel]) -> void:
	hand_view.update_hand(hand)

func _on_combat_loop_deck_updated(deck: Array[CardModel]) -> void:
	deck_view.deck = deck
	deck_view.label_count.text = "%s" % deck.size()

func _on_combat_loop_grave_updated(grave: Array[CardModel]) -> void:
	grave_view.grave = grave
	grave_view.text = "View Graveyard (%s)" % grave.size()



func _on_combat_loop_limbs_updated(_cur: int, _max: int) -> void:
	label_limbs.text = ("Limb #: %s/%s" % [_cur, _max])

func _on_combat_loop_mouth_updated(_cur: int, _max: int) -> void:
	label_mouth.text = ("Mouth #: %s/%s" % [_cur, _max])

func _on_combat_loop_player_hp_changed(current: Variant, maximum: Variant) -> void:
	label_hp.text = ("HP: %s/%s" % [current, maximum])

#endregion


func _on_combat_loop_enemy_selected(enemy_model: EnemyModel) -> void:
	label_enemy_name.text = enemy_model.title
	bar_enemy_hp.max_value = enemy_model.max_hp
	bar_enemy_hp.value = enemy_model.cur_hp
	label_enemy_hp.text = "%s/%s" % [enemy_model.cur_hp, enemy_model.max_hp]
	
	if enemy_model.texture:
		sprite_enemy.texture = enemy_model.texture
	else:
		sprite_enemy.texture = load("res://images/enemies/generic-filler.png")


func _on_combat_loop_enemy_hp_changed(current: int, maximum: int) -> void:
	print("Enemy HP: %s/%s" % [current, maximum])
	bar_enemy_hp.max_value = maximum
	label_enemy_hp.text = "%s/%s" % [current, maximum]
	var tween:= create_tween()
	tween.tween_property(bar_enemy_hp, "value", current, 0.5)
	tween.play()

func _on_combat_loop_enemy_action_decided(action: ActionModel) -> void:
	label_enemy_plan.text = action.description



#region Loop start and end
func _on_combat_loop_loop_started(number: int) -> void:
	label_turn.text = "Turn #%s" % number

func _on_combat_loop_loop_ended(_number: int) -> void:
	pass # Replace with function body.
#endregion

#region Combat start and end
func _on_combat_loop_combat_started() -> void:
	self.show()

func _on_combat_loop_combat_ended(_result: CombatLoop.Result, _turn_number: int, _enemy_name: String) -> void:
	self.hide()
#endregion


#region STATUSES
func _on_combat_loop_enemy_statuses_changed(statuses: Array[StatusModel]) -> void:
	for c in container_enemy_status.get_children():
		c.queue_free()
	
	for status: StatusModel in statuses:
		var icon:= scene_status_icon.instantiate() as StatusIcon
		icon.status = status
		container_enemy_status.add_child(icon)


func _on_combat_loop_player_statuses_changed(statuses: Array[StatusModel]) -> void:
	for c in %StatusContainer.get_children():
		c.queue_free()
	
	for status: StatusModel in statuses:
		var icon:= scene_status_icon.instantiate() as StatusIcon
		icon.status = status
		%StatusContainer.add_child(icon)

#endregion








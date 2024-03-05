class_name ClashState extends Node

signal hp_changed(current, maximum)
signal statuses_changed(status)

@export_category("Stats")
@export var max_hp: int : 
	set(val):
		max_hp = val
		hp_changed.emit(cur_hp, max_hp)
@export var cur_hp: int : 
	set(val):
		cur_hp = val
		hp_changed.emit(cur_hp, max_hp)



var statuses: Array[StatusModel] = []


func start_upkeep() -> void:
	pass

func end_turn() -> void:
	pass




func add_status(status: StatusModel) -> void:
	await get_tree().create_timer(0.0).timeout
	## Stack
	var has_updated: bool = false
	for _s: StatusModel in statuses:
		if _s.title == status.title:
			if _s.can_stack:
				_s.strength += status.strength
				has_updated = true
			if _s.can_stack_duration:
				_s.duration = status.duration
				has_updated = true
			break
	## Nothing to stack
	if not has_updated:
		statuses.append(status)
	statuses_changed.emit(statuses)

func tick_statuses(step: StatusModel.TickTime) -> void:
	var expired: Array[StatusModel] = []
	for status: StatusModel in statuses:
		if status.duration > 0 and status.tick == step:
			status.duration -= 1
			if status.duration <= 0:
				expired.append(status)
	
	for status in expired:
		statuses.erase(status)
	
	statuses_changed.emit(statuses)

func tick_triggers(trigger: StatusModel.Trigger) -> void:
	var expired: Array[StatusModel] = []
	for status: StatusModel in statuses:
		if status.duration > 0 and status.tick == StatusModel.TickTime.TRIGGER:
			if status.trigger == trigger:
				status.duration -= 1
				if status.duration <= 0:
					expired.append(status)
	
	for status in expired:
		statuses.erase(status)
	
	statuses_changed.emit(statuses)












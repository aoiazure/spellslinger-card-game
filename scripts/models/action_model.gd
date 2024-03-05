class_name ActionModel extends RefCounted


## Description of the action.
@export_multiline var description: String = ""
## The function that does the action.
var action: Callable



static func create(_desc: String, fn: Callable) -> ActionModel:
	var model:= ActionModel.new()
	model.description = _desc
	model.action = fn
	
	return model




class_name CostModel extends Resource

enum Type {
	LIMB,
	MOUTH,
	DISCARD
}

## 
@export var type: Type = Type.LIMB
## 
@export_range(0, 10, 1) var amount: int = 1



static func create(_type: Type, _amount: int) -> CostModel:
	var cost:= CostModel.new() 
	cost.type = _type
	cost.amount = _amount
	
	return cost

func _to_string() -> String:
	var s: String = ""
	match type:
		Type.LIMB:
			s = "Limb"
		Type.MOUTH:
			s = "Mouth"
		Type.DISCARD:
			s = "Discard"
	
	s += " %s" % amount
	
	return s




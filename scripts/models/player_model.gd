## Data type that represents a character.
class_name PlayerModel extends CharacterModel

static var Playables: Dictionary = {
	"Sorcerer": Sorcerer.new(),
}

var description: String = ""
## Naive representation of a deck.
var deck: Array[CardModel] = []

class Sorcerer extends PlayerModel:
	func _init() -> void:
		title = "Sorcerer"
		description = "A glass cannon class that scales to end battles quickly."
		deck = [
			CardModel.Fireball.new(), CardModel.Fireball.new(),
			CardModel.Fireball.new(), CardModel.Fireball.new(),
			CardModel.Fireball.new(), CardModel.GrowLimb.new(),
			CardModel.BasicDodge.new(), CardModel.BasicDodge.new(),
			CardModel.OneForTwo.new(), CardModel.OneForTwo.new(),
		]
		
		max_hp = 45
		cur_hp = max_hp







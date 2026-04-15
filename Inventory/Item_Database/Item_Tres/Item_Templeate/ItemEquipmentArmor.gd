extends ItemEquipment
class_name ItemEquipmentArmor

@export var stat_modifiers := {
	"base_defense": 10,
	"health": 40
}

func _init():
	item_type = "equipment"
	max_stack = 1
	slot = SlotType.ARMOR

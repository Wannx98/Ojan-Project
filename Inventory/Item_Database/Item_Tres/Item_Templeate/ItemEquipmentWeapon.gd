extends ItemEquipment
class_name ItemEquipmentWeapon

@export var stat_modifiers := {
	"base_attack": 10,
	"attack_speed": 0.2
}

func _init():
	item_type = "equipment"
	max_stack = 1
	slot = SlotType.WEAPON

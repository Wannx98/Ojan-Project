extends Item
class_name ItemConsumption

@export var cooldown: float = 0.5  # opsional
@export var can_use_when_full: bool = false  # opsional

func use(target):
	# Ini base function
	# Yang override di child class (potion, food, scroll)
	push_warning("ItemConsumption.use() belum di-override")
	return false

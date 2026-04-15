extends Item
class_name ItemPotion

@export var heal: int = 0                # potion heal
@export var temp_attack: int = 0         # buff attack
@export var temp_defense: int = 0        # buff def
@export var duration: float = 0          # berapa detik buff aktif

func _init():
	item_type = "consumable"

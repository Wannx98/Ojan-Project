extends Area2D

@export var item_id: String = "blue_rose_sword"
@export var amount: int = 1
@export var icon: Texture2D

@onready var sprite := $Sprite2D

func _ready():
	if icon:
		sprite.texture = icon
	else:
		print("⚠️ ICON BELUM DISET DI INSPECTOR UNTUK", item_id)
		
func _on_body_entered(body):
	if body.name == "PlayerMC":
		if body.add_item_to_inventory(item_id, amount):
			queue_free()  # hilang dari world
		else:
			print("Inventory full")

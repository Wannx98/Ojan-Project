extends Area2D

@export var item_id: String = "blue_rose_sword"
@export var amount: int = 1

@onready var sprite := $Sprite2D

func _ready():
	var item_data = Item_database.get_item(item_id)
	
	if item_data:
		sprite.texture = item_data.icon
	else:
		print("Item tidak ditemukan:", item_id)

func _on_body_entered(body):
	if body.name == "PlayerMC":
		if body.add_item_to_inventory(item_id, amount):
			queue_free()
		else:
			print("Inventory full")

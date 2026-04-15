extends Resource
class_name PlayerInventory

signal inventory_changed
signal item_collected(item_id: String, amount: int)

@export var max_slots: int = 24
@export var slots: Array[ItemStack] = []

func _init():
	slots.resize(max_slots)
	for i in range(max_slots):
		slots[i] = null

func add_item(item_id: String, amount: int = 1) -> bool:
	print("DEBUG: Trying to add item:", item_id, "x", amount)  # Debug tambahan
	var original_amount := amount
	var item = Item_database.get_item(item_id)
	if item == null:
		print("DEBUG: Item not found in database")  # Debug
		return false

	print("DEBUG: Item found, max_stack:", item.max_stack)  # Debug

	# 1. Try stacking
	for i in range (slots.size()):
		var s = slots[i]
		if s and s.item == item:
			var can_add = item.max_stack - s.amount
			if can_add > 0:
				var add = min(can_add, amount)
				s.amount += add
				amount -= add
				if amount <= 0:
					print("DEBUG: Item stacked successfully")
					emit_signal("inventory_changed")  # Debug
					emit_signal("item_collected", item_id, original_amount)
					return true

	# 2. Empty slot
	for i in range(slots.size()):
		if slots[i] == null:
			var new_s = ItemStack.new()
			new_s.item = item
			new_s.amount = min(amount, item.max_stack)
			slots[i] = new_s
			amount -= new_s.amount
			if amount <= 0:
				print("DEBUG: Item added to empty slot")
				emit_signal("inventory_changed")  # Debug
				emit_signal("item_collected", item_id, original_amount)
				return true

	print("DEBUG: Failed to add item (inventory full?)")  # Debug
	return false

extends Node
class_name Inventory

@export var max_slots: int = 24
var slots: Array[ItemStack] = []


func _ready():
	# initialize slot list with empty stacks (null)
	slots.resize(max_slots)
	for i in slots.size():
		slots[i] = null


func add_item(item_id: String, amount: int = 1) -> bool:
	var item = Item_database.get_item(item_id)
	if item == null:
		push_error("Item %s not found" % item_id)
		return false

	# 1. Try stack into existing stacks
	for i in slots.size():
		var stack = slots[i]
		if stack and stack.item == item:
			var can_add = item.max_stack - stack.amount
			if can_add > 0:
				var to_add = min(can_add, amount)
				stack.amount += to_add
				amount -= to_add
				if amount <= 0:
					return true

	# 2. Place into empty slot
	for i in slots.size():
		if slots[i] == null:
			var new_stack = ItemStack.new()
			new_stack.item = item
			new_stack.amount = min(amount, item.max_stack)
			slots[i] = new_stack
			amount -= new_stack.amount
			if amount <= 0:
				return true

	# If still leftover → inventory full
	return false


func remove_item(item_id: String, amount: int = 1) -> bool:
	for i in slots.size():
		var stack = slots[i]
		if stack and stack.item.id == item_id:
			if stack.amount >= amount:
				stack.amount -= amount
				if stack.amount == 0:
					slots[i] = null
				return true
	return false

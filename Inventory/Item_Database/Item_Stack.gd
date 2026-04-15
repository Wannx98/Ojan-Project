extends Resource
class_name ItemStack

@export var item: Item
@export var amount: int = 1

func add_amount(value: int):
	amount += value

func remove_amount(value: int):
	amount = max(0, amount - value)

func is_empty() -> bool:
	return amount <= 0

func clone_with_amount(v: int) -> ItemStack:
	var c = ItemStack.new()
	c.item = self.item
	c.amount = v
	return c

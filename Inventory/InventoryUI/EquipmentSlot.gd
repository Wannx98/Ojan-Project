extends TextureButton
class_name EquipmentSlot

@export var slot_type: ItemEquipment.SlotType

var item: Item = null
signal return_to_inventory(stack)

@onready var icon_node: TextureRect = $Icon

# =========================
# GET PLAYER
# =========================
func get_player():
	var p = get_tree().get_first_node_in_group("player")
	if p == null:
		push_warning("⚠ Player NOT FOUND in 'player' group")
	return p


# =========================
# SET ITEM (EQUIP or REPLACE)
# =========================
func set_item(new_item: Item):
	var player = get_player()

	# Reject wrong slot
	if new_item and new_item is ItemEquipment and new_item.slot != slot_type:
		return

	# Hapus modifier item lama
	if item and player:
		player.player_stats.remove_modifier("equip_" + item.id)

	# Pasang item baru
	item = new_item
	icon_node.texture = item.icon if item else null

	# Apply modifier item baru
	if item and player:
		player.player_stats.apply_modifier("equip_" + item.id, item.stat_modifiers)

	if player:
		player.emit_signal("stats_changed")


# =========================
# CLEAR ITEM / UNEQUIP
# =========================
func clear_item():
	var player = get_player()

	if item and player:
		player.player_stats.remove_modifier("equip_" + item.id)
		player.emit_signal("stats_changed")

	item = null
	icon_node.texture = null


# =========================
# DRAG (UNEQUIP)
# =========================
func _get_drag_data(_pos):
	if item == null:
		return null

	var preview = icon_node.duplicate() as TextureRect
	preview.modulate = Color(1,1,1,0.7)
	preview.global_position = get_global_mouse_position()
	set_drag_preview(preview)

	var drag_stack := ItemStack.new()
	drag_stack.item = item
	drag_stack.amount = 1

	# HAPUS modifier yang bener
	var player = get_player()
	if player:
		player.player_stats.remove_modifier("equip_" + item.id)
		player.emit_signal("stats_changed")

	# Kosongkan slot
	item = null
	icon_node.texture = null

	return {
		"type": "equipment",
		"stack": drag_stack,
		"from_equipment": self
	}


# =========================
# DROP (EQUIP)
# =========================
func _can_drop_data(_pos, data):
	if typeof(data) != TYPE_DICTIONARY:
		return false
	if not data.has("stack"):
		return false

	var stack: ItemStack = data["stack"]
	if stack == null:
		return false

	if not (stack.item is ItemEquipment):
		return false

	return stack.item.slot == slot_type


func _drop_data(_pos, data):
	var stack: ItemStack = data["stack"]

	if not _can_drop_data(_pos, data):
		emit_signal("return_to_inventory", stack)
		return

	var from_slot = data.get("slot")

	# Ambil satu
	if stack.amount > 1:
		var return_amount = stack.amount - 1
		var return_stack = stack.clone_with_amount(return_amount)
		emit_signal("return_to_inventory", return_stack)
		stack.amount = 1

	# EQUIP
	item = stack.item
	icon_node.texture = item.icon

	var player = get_player()
	if player:
		player.player_stats.apply_modifier("equip_" + item.id, item.stat_modifiers)
		player.emit_signal("stats_changed")

	# Hapus dari inventory
	if from_slot:
		from_slot.stack.amount -= 1
		if from_slot.stack.amount <= 0:
			from_slot.stack = null
		from_slot.update_slot()

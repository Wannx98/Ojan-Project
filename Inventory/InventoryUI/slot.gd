extends Panel
class_name InventorySlot

signal slot_changed

# Aman: coba dua kemungkinan nama node icon
@onready var icon_node: TextureRect = find_child("Icon", true, false)
@onready var count_label: Label = find_child("Count", true, false)


# stack: ItemStack Resource atau null
var stack: Resource = null

func _ready():
	update_slot()

# Dipanggil oleh InventoryUI untuk set/update data stack
func set_stack(new_stack: Resource) -> void:
	stack = new_stack
	update_slot()

func clear_slot() -> void:
	stack = null
	update_slot()

func update_slot() -> void:
	if icon_node == null or count_label == null:
		# fallback warning supaya lo tahu kalau node path beda
		# (bisa dihapus setelah lo pastikan nama node benar)
		#print("⚠️ InventorySlot: icon or count node not found")
		return

	if stack == null:
		icon_node.texture = null
		count_label.text = ""
		return

	# stack.item harus refer ke Item Resource (class Item)
	var item_res = null
	# support dua pola: stack.item (Resource) atau stack.item_id (String) 
	if "item" in stack:
		item_res = stack.item
	elif "item_id" in stack:
		item_res = Item_database.get_item(stack.item_id)

	# set icon
	if item_res and item_res.icon:
		icon_node.texture = item_res.icon
	else:
		icon_node.texture = null

	# jumlah
	var amt = 0
	if "amount" in stack:
		amt = stack.amount
	elif "quantity" in stack:
		amt = stack.quantity
	elif "qty" in stack:
		amt = stack.qty

	count_label.text = (str(amt) if amt > 1 else "")

# ===============================
# DRAG & DROP
# ===============================
var dragging_preview: Control = null

func _gui_input(event: InputEvent) -> void:
	if stack == null:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var preview = icon_node.duplicate() as TextureRect
		preview.modulate = Color(1,1,1,0.7)
		preview.global_position = get_global_mouse_position()
		set_drag_preview(preview)

# helper buat duplicate icon sebagai preview transparan
func make_drag_preview() -> Control:
	var preview = Control.new()
	preview.set_custom_minimum_size(icon_node.get_size())
	
	get_tree().current_scene.add_child(preview)
	preview.global_position = get_global_mouse_position()  # posisi sesuai mouse
	dragging_preview = preview
	return preview

# override method bawaan
func _get_drag_data(_position):
	if stack == null:
		return null

	# buat preview
	var preview = icon_node.duplicate() as TextureRect
	preview.modulate = Color(1,1,1,0.7)
	preview.global_position = get_global_mouse_position()
	set_drag_preview(preview)
	
	var drag_stack : ItemStack = null

	# SHIFT → split setengah
	if Input.is_key_pressed(KEY_SHIFT) and stack.amount > 1:
		var half = int(ceil(stack.amount / 2.0))

		# bikin stack baru utk drag
		drag_stack = stack.clone_with_amount(half)

		# kurangi slot asal
		stack.amount -= half

		# safety biar ga hilang
		if stack.amount < 1:
			stack.amount = 1

		update_slot()
	else:
		# tanpa split → bawa full stack
		drag_stack = stack
	return {
		"slot": self,
		"stack": drag_stack
	}

func _can_drop_data(_position, data) -> bool:
	# Nerima dari inventory (ada "slot") atau dari equipment (ada "from_equipment")
	return typeof(data) == TYPE_DICTIONARY and data.has("stack") and (data.has("slot") or data.has("from_equipment"))
	
func _drop_data(_position, data) -> void:
	var from_stack: ItemStack = data["stack"]
	if data == null or from_stack == null:
		return
	
	# Handling dari equipment
	if data.has("from_equipment"):
		var eq_slot: EquipmentSlot = data["from_equipment"]
		var eq_stack: ItemStack = data["stack"]
		
		if stack == null:
			# Slot kosong: pindah item dari equipment
			stack = from_stack
			update_slot()
			eq_slot.clear_item()
		else:
			# Slot ada isi: swap
			var temp = stack
			stack = from_stack
			update_slot()
			eq_slot.set_item(temp.item)
		emit_signal("slot_changed")
		return
	
	# Handling dari inventory (slot lain)
	var from_slot : InventorySlot = data["slot"]
	if from_slot == self:
		return

	# SLOT KOSONG
	if stack == null:
		stack = from_stack
		from_slot.stack = null
		update_slot()
		from_slot.update_slot()
		emit_signal("slot_changed")
		return

	# STACKING
	if stack.item == from_stack.item:
		var space = stack.item.max_stack - stack.amount
		var add_amt = min(space, from_stack.amount)

		# Tambahin ke slot tujuan
		stack.amount += add_amt

		# Kurangi slot asal
		from_slot.stack.amount -= add_amt

		# Kalau slot asal habis → null
		if from_slot.stack.amount <= 0:
			from_slot.stack = null

		update_slot()
		from_slot.update_slot()
		emit_signal("slot_changed")
		return

	# SWAP
	var temp = stack
	stack = from_stack
	from_slot.stack = temp

	update_slot()
	from_slot.update_slot()
	emit_signal("slot_changed")
	return

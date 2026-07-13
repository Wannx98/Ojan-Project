extends Node2D
class_name InventoryUI

@onready var grid := $GridContainer
var slots := []

var player  # Player reference

#SET STATS UI===
@onready var hp_label = $PlayerStatsUI/Panel/hp_label
@onready var atk_label = $PlayerStatsUI/Panel/atk_label
@onready var def_label = $PlayerStatsUI/Panel/def_label

# =====================================================
# SET PLAYER
# =====================================================
func set_player(p):
	player = p
	if player:
		player.connect("inventory_changed", Callable(self, "refresh_ui"))# Connect signal buat auto-refresh
		player.stats_changed.connect(update_stats)  
	refresh_ui()
	update_stats()

func update_stats():
	if player == null:
		return

	var stats = player.player_stats

	hp_label.text = "HP : %d / %d" % [
		stats.health,
		stats.max_health
	]

	atk_label.text = "ATK : %d" % stats.get_stat("base_attack")
	def_label.text = "DEF : %d" % stats.get_stat("base_defense")



# =====================================================
# READY
# =====================================================
func _ready():
	for s in grid.get_children():
		slots.append(s)
		s.slot_changed.connect(save_to_inventory)

# =====================================================
# SAVE INVENTORY KE PLAYER
# =====================================================
func save_to_inventory():
	if player == null or player.inventory == null:
		return

	for i in range(slots.size()):
		player.inventory.slots[i] = slots[i].stack

# =====================================================
# REFRESH UI SESUAI PLAYER INVENTORY
# =====================================================
func refresh_ui():
	if player == null or player.inventory == null:
		print("DEBUG: Player or inventory null, skipping refresh")  # Debug
		return

	# Clear semua icon slot UI
	for s in slots:
		s.clear_slot()

	# Ambil inventory dari player
	var inv = player.inventory.slots
	print("DEBUG: Refreshing UI, inv size:", inv.size(), "slots size:", slots.size())  # Debug

	for i in range(inv.size()):
		if i >= slots.size():
			break

		var st = inv[i]
		if st != null:
			print("DEBUG: Setting slot", i, "with", st.item, "x", st.amount)  # Debug
			slots[i].set_stack(st)


# =====================================================
# RETURN STACK JIKA EQUIP DILEPAS
# =====================================================
func return_stack(stack: Resource):
	for s in slots:
		if s.stack == null:
			s.set_stack(stack)
			save_to_inventory()
			return

	print("⚠️ Inventory full, item tidak bisa dikembalikan:", stack)

# =====================================================
# TOGGLE UI
# =====================================================


func toggle():
	visible = !visible


# TAMBAHAN: Input buat test manual
#func _input(event):
#	if event.is_action_pressed("ui_accept"):  # Tekan Enter buat test add items
#		test_add_items()
#	if event.is_action_pressed("ui_cancel"):  # Tekan Esc buat toggle UI
#		toggle()

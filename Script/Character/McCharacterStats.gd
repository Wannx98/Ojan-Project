extends Resource
class_name PlayerStats

# Base stats
@export var max_health: int = 100
@export var health: int = 100
@export var base_attack: int = 10
@export var base_defense: int = 5
@export var movement_speed: float = 200.0

# Additional / derived
@export var critical_chance: float = 0.05  # 5%
@export var attack_speed: float = 1.0      # multiplier

# Modifiers container (dictionary of sources -> dict of stat changes)
var modifiers: Dictionary = {}

# Utility: compute effective stat (base + sum of modifiers)
func get_stat(stat_name: String) -> float:
	var base_val = 0.0

	# Cek apakah stat_name adalah variable yang memang ada di resource
	for p in get_property_list():
		if p.name == stat_name:
			base_val = self.get(stat_name)
			break

	var total_mod = 0.0
	for src in modifiers.keys():
		var m = modifiers[src]
		if m.has(stat_name):
			total_mod += float(m[stat_name])

	return base_val + total_mod

# Apply modifier by id (e.g., "equip_helmet")
func apply_modifier(id: String, data: Dictionary) -> void:
	modifiers[id] = data

func remove_modifier(id: String) -> void:
	if modifiers.has(id):
		modifiers.erase(id)

extends Panel
class_name PlayerStatsUI

@onready var health_bar: ProgressBar = $VBoxContainer/Health/health_bar
@onready var attack_label: Label = $VBoxContainer/Attack/attack_value
@onready var defense_label: Label = $VBoxContainer/Defense/defense_value
@onready var speed_label: Label = $VBoxContainer/Speed/speed_value

var player = null

func _ready():
	# Cari player di scene
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("⚠ Player NOT FOUND in 'player' group")
		return
	refresh_stats()

func refresh_stats():
	if player == null:
		return

	var stats = player.stats
	if stats == null:
		return

	# Update UI
	health_bar.max_value = stats.max_health
	health_bar.value = stats.health
	attack_label.text = str(stats.base_attack)
	defense_label.text = str(stats.base_defense)
	speed_label.text = str(stats.movement_speed)

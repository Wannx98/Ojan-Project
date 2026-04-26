extends Node2D

var current_map : Node = null


func _ready() -> void:
	
	$"/root/Quest_Manager".load_all_quests("res://QuestSystem/Data/QuestList/")
	$"/root/Quest_Manager".accept_quest("talk_bartender")
	
	
	# Load map pertama saat game mulai
	change_map("res://Scene/Town.tscn", "spawnawal")
	
	if inventory_ui != null and $PlayerMC != null:
		inventory_ui.set_player($PlayerMC)
	else:
		print("WARN: inventory_ui atau PlayerMC null saat _ready()")
		
func change_map(scene_path: String, spawn_point_name: String) -> void:
	if current_map != null and current_map.is_inside_tree():
		current_map.queue_free()
		current_map = null

	var scene_res = load(scene_path)
	if scene_res == null:
		print("ERROR: Scene tidak ditemukan:", scene_path)
		return

	current_map = scene_res.instantiate()
	$MapHolder.add_child(current_map)

	var spawn = current_map.get_node(spawn_point_name)
	if spawn != null and $PlayerMC != null:
		$PlayerMC.global_position = spawn.global_position
		
		

@onready var inventory_ui = $CanvasLayer/Manager/Inventory

func _input(event):
	if event.is_action_pressed("Inventory"):
		inventory_ui.toggle()

 

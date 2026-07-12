extends Area2D
class_name Princess_NPC

@export var npc_id: String = "Princess"
@export var dialog_lines: Array[String]


signal interacted(npc_id: String)

var player_in_range := false

func _ready():
	add_to_group("npc")
	
func _process(delta):
	if player_in_range and Input.is_action_just_pressed("Interact"):
		interact()
		
func interact():
	print("NPC interacted:", npc_id)
	emit_signal("interacted", npc_id)
	Quest_Manager.on_npc_interacted(npc_id)

func _on_body_entered(body):
	if body.name == "PlayerMC":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "PlayerMC":
		player_in_range = false
		

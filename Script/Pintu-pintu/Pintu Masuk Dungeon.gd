extends Area2D

@export var next_scene: String = "res://Scene/dungeon.tscn"
@export var target_spawn: String = "spawndungeon"

var player_in_area: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "PlayerMC":
		player_in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "PlayerMC":
		player_in_area = false

func _process(_delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("Interact"):
		var main_scene = get_tree().current_scene
		if main_scene:
			main_scene.change_map(next_scene, target_spawn)

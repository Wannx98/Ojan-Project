
extends Area2D

@export var next_scene: String = "res://Scene/game.tscn"

var player_in_area: bool = false

func _on_body_entered(body: Node2D) -> void:
	print("ENTER:", body.name)
	if body.name == "PlayerMC":   # ganti sesuai nama player kamu
		player_in_area = true

func _on_body_exited(body: Node2D) -> void:
	print("EXIT:", body.name)
	if body.name == "PlayerMC":   # ganti sesuai nama player kamu
		player_in_area = false

func _process(_delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("Interact"):
		print("GANTI SCENE:", next_scene)
		get_tree().change_scene_to_file(next_scene)

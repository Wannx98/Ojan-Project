extends Node

const SAVE_PATH := "user://savegame.json"


func save_game() -> void:
	var current_scene := get_tree().current_scene

	if current_scene == null:
		print("Save gagal: current_scene tidak ditemukan")
		return

	var player := current_scene.get_node_or_null("PlayerMC")

	if player == null:
		print("Save gagal: PlayerMC tidak ditemukan")
		return

	var save_data := {
		"scene_path": current_scene.scene_file_path,
		"player_position": {
			"x": player.global_position.x,
			"y": player.global_position.y
		}
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("Save gagal: file tidak bisa dibuat")
		return

	file.store_string(JSON.stringify(save_data))
	file.close()

	print("Game berhasil disimpan")


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Load gagal: file save belum ada")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		print("Load gagal: file save tidak bisa dibuka")
		return

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var result := json.parse(json_text)

	if result != OK:
		print("Load gagal: data save rusak")
		return

	var save_data: Dictionary = json.data
	var scene_path: String = save_data.get("scene_path", "res://Scene/main_scene.tscn")

	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)

	await get_tree().process_frame
	await get_tree().process_frame

	var current_scene := get_tree().current_scene

	if current_scene == null:
		print("Load gagal: current_scene tidak ditemukan")
		return

	var player := current_scene.get_node_or_null("PlayerMC")

	if player == null:
		print("Load posisi gagal: PlayerMC tidak ditemukan")
		return

	var pos_data: Dictionary = save_data.get("player_position", {})

	var x := float(pos_data.get("x", player.global_position.x))
	var y := float(pos_data.get("y", player.global_position.y))

	player.global_position = Vector2(x, y)

	print("Game berhasil dimuat")


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

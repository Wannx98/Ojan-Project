extends Control

@onready var dark_background: ColorRect = $DarkBackground

@onready var resume_button: BaseButton = $CenterContainer/Panel/VBoxContainer/ResumeButton
@onready var save_button: BaseButton = $CenterContainer/Panel/VBoxContainer/SaveButton
@onready var main_menu_button: BaseButton = $CenterContainer/Panel/VBoxContainer/MainMenuButton
@onready var quit_button: BaseButton = $CenterContainer/Panel/VBoxContainer/QuitButton

var is_paused := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	_setup_pause_background()
	_setup_buttons()
	_connect_buttons()


func _setup_pause_background() -> void:
	dark_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dark_background.color = Color(0, 0, 0, 0.85)


func _setup_buttons() -> void:
	var buttons := [
		resume_button,
		save_button,
		main_menu_button,
		quit_button
	]

	for button in buttons:
		button.process_mode = Node.PROCESS_MODE_ALWAYS
		button.custom_minimum_size = Vector2(240, 75)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_setup_button_effect(button)


func _connect_buttons() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()


func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	visible = is_paused

	_set_quest_ui_visible(!is_paused)

	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_resume_pressed() -> void:
	_play_button_click_effect(resume_button)

	is_paused = false
	get_tree().paused = false
	visible = false

	_set_quest_ui_visible(true)


func _on_save_pressed() -> void:
	_play_button_click_effect(save_button)

	var save_manager := get_node_or_null("/root/SaveManager")

	if save_manager:
		save_manager.save_game()
		print("Game berhasil disimpan dari Pause Menu")
	else:
		print("Save gagal: SaveManager belum terdaftar di AutoLoad")


func _on_main_menu_pressed() -> void:
	_play_button_click_effect(main_menu_button)

	get_tree().paused = false
	_set_quest_ui_visible(true)

	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")


func _on_quit_pressed() -> void:
	_play_button_click_effect(quit_button)

	await get_tree().create_timer(0.15).timeout
	get_tree().quit()


func _set_quest_ui_visible(state: bool) -> void:
	var current_scene := get_tree().current_scene

	if current_scene == null:
		return

	var quest_ui := current_scene.get_node_or_null("QuestUI")

	if quest_ui:
		quest_ui.visible = state


func _setup_button_effect(button: BaseButton) -> void:
	button.pivot_offset = button.size / 2

	button.mouse_entered.connect(_on_button_hover.bind(button))
	button.mouse_exited.connect(_on_button_exit.bind(button))
	button.button_down.connect(_on_button_down.bind(button))
	button.button_up.connect(_on_button_up.bind(button))


func _on_button_hover(button: BaseButton) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.10)


func _on_button_exit(button: BaseButton) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.10)


func _on_button_down(button: BaseButton) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(button, "scale", Vector2(1.10, 1.10), 0.07)


func _on_button_up(button: BaseButton) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.07)


func _play_button_click_effect(button: BaseButton) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(button, "scale", Vector2(1.12, 1.12), 0.06)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.08)

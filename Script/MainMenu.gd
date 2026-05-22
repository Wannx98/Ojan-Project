extends Control

@onready var start_button: BaseButton = $ColorRect/CenterContainer/VBoxContainer/StartButton
@onready var continue_button: BaseButton = $ColorRect/CenterContainer/VBoxContainer/ContinueButton
@onready var setting_button: BaseButton = $ColorRect/CenterContainer/VBoxContainer/SettingButton
@onready var quit_button: BaseButton = $ColorRect/CenterContainer/VBoxContainer/QuitButton

@onready var setting_panel: Control = $SettingPanel
@onready var music_button: BaseButton = $SettingPanel/CenterContainer/Panel/SettingBox/MusicButton
@onready var back_button: BaseButton = $SettingPanel/CenterContainer/Panel/SettingBox/BackButton

@onready var bgm: AudioStreamPlayer = $BGM
@onready var click_sfx: AudioStreamPlayer = $ClickSFX
@onready var fade_rect: ColorRect = $FadeRect

var music_on := true


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	setting_panel.visible = false
	continue_button.visible = SaveManager.has_save()

	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.modulate.a = 1.0

	var fade_in := create_tween()
	fade_in.tween_property(fade_rect, "modulate:a", 0.0, 0.6)

	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	setting_button.pressed.connect(_on_setting_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	music_button.pressed.connect(_on_music_pressed)
	back_button.pressed.connect(_on_back_pressed)

	await get_tree().process_frame

	_setup_button_effect(start_button)
	_setup_button_effect(continue_button)
	_setup_button_effect(setting_button)
	_setup_button_effect(quit_button)
	_setup_button_effect(music_button)
	_setup_button_effect(back_button)

	_update_music_button_color()


func _on_start_pressed() -> void:
	_play_click()

	_disable_main_buttons()

	var fade_out := create_tween()
	fade_out.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	await fade_out.finished

	get_tree().change_scene_to_file("res://MAIN/main_scene.tscn")


func _on_continue_pressed() -> void:
	_play_click()

	_disable_main_buttons()

	var fade_out := create_tween()
	fade_out.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	await fade_out.finished

	SaveManager.load_game()


func _on_setting_pressed() -> void:
	_play_click()
	setting_panel.visible = true


func _on_quit_pressed() -> void:
	_play_click()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()


func _on_music_pressed() -> void:
	_play_click()

	music_on = !music_on
	bgm.stream_paused = !music_on

	_update_music_button_color()


func _on_back_pressed() -> void:
	_play_click()
	setting_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if setting_panel.visible:
			setting_panel.visible = false


func _disable_main_buttons() -> void:
	start_button.disabled = true
	continue_button.disabled = true
	setting_button.disabled = true
	quit_button.disabled = true


func _update_music_button_color() -> void:
	if music_on:
		music_button.modulate = Color(1, 1, 1, 1)
	else:
		music_button.modulate = Color(0.45, 0.45, 0.45, 1)


func _play_click() -> void:
	if click_sfx:
		click_sfx.play()


func _setup_button_effect(button: BaseButton) -> void:
	button.pivot_offset = button.size / 2

	button.mouse_entered.connect(_on_button_hover.bind(button))
	button.mouse_exited.connect(_on_button_exit.bind(button))
	button.button_down.connect(_on_button_down.bind(button))
	button.button_up.connect(_on_button_up.bind(button))


func _on_button_hover(button: BaseButton) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.10)


func _on_button_exit(button: BaseButton) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.10)


func _on_button_down(button: BaseButton) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(1.10, 1.10), 0.07)


func _on_button_up(button: BaseButton) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.07)

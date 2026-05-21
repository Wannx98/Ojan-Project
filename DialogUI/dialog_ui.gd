extends CanvasLayer
class_name DialogUI

@onready var dialog_label = $Panel/Label
@export var typing_speed := 0.03

var lines := []
var current_line := 0
var is_typing := false
var skip_typing := false

signal dialog_finished(npc_id)

var current_npc := ""

func _unhandled_input(event):
	if not visible:
		return

	if event.is_action_pressed("next_dialog"):
		next_line()

func start_dialog(npc_id: String, npc_lines: Array):
	current_npc = npc_id
	lines = npc_lines
	current_line = 0
	visible = true
	_show_line()

func _show_line():
	if current_line >= lines.size():
		emit_signal("dialog_finished", current_npc)
		visible = false
		return

	is_typing = true
	dialog_label.text = ""
	var text = lines[current_line]
	_typewriter(text)

func _typewriter(text: String) -> void:
	for i in range(text.length()):
		if skip_typing:
			dialog_label.text = text
			break
		dialog_label.text += text[i]
		await get_tree().create_timer(typing_speed).timeout
	is_typing = false

func next_line():
	if is_typing:
		skip_typing = true
		return
	current_line += 1
	skip_typing = false
	_show_line()

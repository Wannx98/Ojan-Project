extends CanvasLayer
class_name QuestUI

# Node references
@onready var title_label = $Control/Panel/VBoxContainer/QuestTitle
@onready var desc_label = $Control/Panel/VBoxContainer/QuestDescription
@onready var progress_label = $Control/Panel/VBoxContainer/QuestProgressText
var current_quest_id := ""

func _ready():
	visible = true  # Popup default hidden

	print("QuestPopup ready")
	print("Quest_Manager:", Quest_Manager)
	

	# Connect ke QuestManager signal
	if Quest_Manager:
		Quest_Manager.connect("quest_updated", Callable(self, "_on_quest_updated"))
	else:
		print("❌ QuestManager tidak ditemukan!")

# Function dijalankan saat QuestManager emit signal
func _on_quest_updated(quest: Quest):
	print("Quest title:", quest.title)
	print("Quest desc:", quest.description)
	print("Quest progress:", quest.progress, "/", quest.goal)
	
	current_quest_id = quest.id
	visible = true
	title_label.text = quest.title
	desc_label.text = quest.description

	if quest.status == Quest.Status.COMPLETED:
		_show_completed()
	else:
		_show_progress(quest)

# Update progress label
func _show_progress(quest: Quest):
	progress_label.text = "%d / %d" % [quest.progress, quest.goal]

# Tampilkan quest completed
func _show_completed():
	progress_label.text = "Quest Completed!"

	# Auto-hide setelah 2 detik
	await get_tree().create_timer(2.0).timeout

	visible = true

extends Node
class_name QuestManager

var quests: Dictionary = {} # quest_id : Quest

signal quest_updated(quest: Quest)


@onready var dialog_ui := get_tree().get_first_node_in_group("dialog_ui")

func _ready():
	load_all_quests("res://QuestSystem/Data/QuestList/")
	print("Loaded quests:", quests.keys())

	

	#NPC connect
	for npc in get_tree().get_nodes_in_group("npc"):
		if not npc.is_connected("interacted", Callable(self, "on_npc_interacted")):
			npc.connect("interacted", Callable(self, "on_npc_interacted"))
	
	#Enemy connect
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.connect("killed", Callable(self, "on_enemy_killed"))
		
	#Player Inventory connect(for picup item quest)
	var player = get_tree().get_first_node_in_group("player")
	if player and player.inventory:
		player.inventory.connect(
			"item_collected",
			Callable(self, "on_item_collected")
		)
	if dialog_ui:
		dialog_ui.connect("dialog_finished", Callable(self, "_on_dialog_finished"))
	else:
		push_warning("DialogUI not found in group 'dialog_ui'")
	
func load_all_quests(path: String):
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Quest folder not found: " + path)
		return

	dir.list_dir_begin()
	var file := dir.get_next()

	while file != "":
		if file.ends_with(".tres"):
			var quest: Quest = load(path + "/" + file)
			register_quest(quest)
		file = dir.get_next()

func register_quest(quest: Quest):
	if quests.has(quest.id):
		return
	quests[quest.id] = quest

func accept_quest(id: String):
	if !quests.has(id):
		print("❌ Quest ID tidak ditemukan:", id)
		return

	var quest: Quest = quests[id]
	print("Accepting quest:", quest.id, "status:", quest.status)

	if quest.status != Quest.Status.LOCKED:
		print("❌ Quest sudah aktif atau completed:", id)
		return

	quest.status = Quest.Status.ACTIVE
	print("Quest accepted:", quest.title)
	print("Accepting quest:", quest.id, "status:", quest.status)
	emit_signal("quest_updated", quest)


func on_npc_interacted(npc_id: String):
	print("QuestManager received npc:", npc_id)
	for quest in quests.values():
		if quest.status != Quest.Status.ACTIVE:
			continue

		if quest.type == "talk" and quest.target == npc_id:
			print("✅ Talk quest matched:", quest.id)
			# ambil NPC node
			for npc in get_tree().get_nodes_in_group("npc"):
				if npc.npc_id == npc_id:
					if dialog_ui:
						dialog_ui.start_dialog(npc_id, npc.dialog_lines)
					else:
						push_warning("DialogUI missing")
					return
			


func _on_dialog_finished(npc_id: String):
	for quest in quests.values():
		if quest.status != Quest.Status.ACTIVE:
			continue

		if quest.type == "talk" and quest.target == npc_id:
			add_progress(quest.id)


func on_enemy_killed(enemy_id: String):
	print("🧪 QuestManager received enemy kill:", enemy_id)
	for quest in quests.values():
		if quest.status != Quest.Status.ACTIVE:
			continue
		print("🧪 Checking quest:", quest.id, quest.type, quest.target)

		if quest.type == "kill" and quest.target == enemy_id:
			print("✅ Kill quest matched!")
			add_progress(quest.id)
			
#fix  sementara harusnya (enemy: Enemy) paling ideal
func register_enemy(enemy: CharacterBody2D ):
	if not enemy.is_connected("killed", Callable(self, "on_enemy_killed")):
		enemy.connect("killed", Callable(self, "on_enemy_killed"))

			
func on_item_collected(item_id: String, amount : int):
	for quest in quests.values():
		if quest.status != Quest.Status.ACTIVE:
			continue

		if quest.type == "collect" and quest.target == item_id:
			add_progress(quest.id, amount)


func add_progress(id: String, amount := 1):
	if !quests.has(id):
		return

	var quest: Quest = quests[id]

	if quest.status != Quest.Status.ACTIVE:
		return

	quest.progress += amount
	quest.progress = min(quest.progress, quest.goal)

	if quest.progress >= quest.goal:
		complete_quest(quest)
		return

	emit_signal("quest_updated", quest)

func get_active_quest() -> Quest:
	for quest in quests.values():
		if quest.status == Quest.Status.ACTIVE:
			return quest
	return null

func complete_quest(quest: Quest):
	if quest.status == Quest.Status.COMPLETED:
		return
		
	quest.status = Quest.Status.COMPLETED
	print("Quest completed:", quest.title)

	emit_signal("quest_updated", quest)
	# 🔗 QUEST BERIKUTNYA
	if quest.next_quest_id != "":
		accept_quest(quest.next_quest_id)

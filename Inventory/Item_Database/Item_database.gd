extends Node
class_name ItemDatabase

var items: Dictionary = {}   # key = item.id, value = Item Resource

func _ready():
	items = load_item_database("res://Inventory/Item_Database/Item_Tres/")

func load_item_database(path: String) -> Dictionary:
	var db := {}
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Folder not found: %s" % path)
		return db

	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if not dir.current_is_dir():
			if fname.ends_with(".tres"):
				var full = path.path_join(fname)
				var res = ResourceLoader.load(full)
				if res and res is Item:
					if res.id == "":
						push_warning("Item %s has empty id" % fname)
					else:
						db[res.id] = res
		fname = dir.get_next()

	dir.list_dir_end()
	return db


func get_item(item_id: String) -> Item:
	return items.get(item_id, null)

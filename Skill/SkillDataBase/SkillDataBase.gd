extends Node
class_name SkillDatabase

var skills: Dictionary = {}

func _ready():
	skills = load_skills("res://Skill/SkillDataBase/SkillTres/")

func load_skills(path: String) -> Dictionary:
	var db := {}
	var dir = DirAccess.open(path)

	if dir == null:
		push_error("Skill folder not found")
		return db

	dir.list_dir_begin()
	var fname = dir.get_next()

	while fname != "":
		if not dir.current_is_dir() and fname.ends_with(".tres"):
			var res = ResourceLoader.load(path.path_join(fname))

			if res and res is SkillData:
				if res.id == "":
					push_warning("Skill without ID:", fname)
				elif db.has(res.id):
					push_error("Duplicate skill ID:", res.id)
				else:
					db[res.id] = res

		fname = dir.get_next()

	dir.list_dir_end()
	return db

func get_skill(id: String) -> SkillData:
	var s = skills.get(id, null)
	if s:
		return s.duplicate() # 🔥 penting
	return null

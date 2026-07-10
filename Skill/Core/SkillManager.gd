extends Node
class_name SkillManager

@export var skill_owner: CharacterBody2D

var owned_skills: Dictionary = {}
var cooldowns: Dictionary = {}

func _process(delta):

	for id in cooldowns.keys():

		if cooldowns[id] > 0:
			cooldowns[id] -= delta

			if cooldowns[id] <= 0:
				cooldowns[id] = 0


func learn_skill(skill: SkillData):

	if owned_skills.has(skill.id):
		return

	owned_skills[skill.id] = skill
	cooldowns[skill.id] = 0


func forget_skill(id:String):

	owned_skills.erase(id)
	cooldowns.erase(id)


func has_skill(id:String)->bool:

	return owned_skills.has(id)


func can_cast(id:String)->bool:
	
	print("CHECKING ID:", id, " | owned keys:", owned_skills.keys(), " | has:", owned_skills.has(id))
	if !owned_skills.has(id):
		return false

	return cooldowns[id] <= 0


func cast(id:String):

	if !can_cast(id):
		return

	var skill:SkillData = owned_skills[id]
	print("CASTING:", id, " scene:", skill.skill_scene, " skill_owner:", skill_owner, " COOLDOWN VALUE:", skill.cooldown)

	cooldowns[id] = skill.cooldown

	if skill.skill_scene:

		var instance = skill.skill_scene.instantiate()

		get_tree().current_scene.add_child(instance)

		instance.cast(skill_owner, skill)
	else:
		push_warning("Skill '%s' tidak punya skill_scene di-assign!" % id)

extends Node2D
class_name BaseSkill

var skill_owner
var skill_data: SkillData

func cast(user, skill):
	skill_owner = user
	skill_data = skill

extends Resource
class_name SkillData

@export var name: String
@export var cooldown: float
@export var mana_cost: int

func can_use(user) -> bool:
	return user.current_mana >= mana_cost

func execute(user):
	pass

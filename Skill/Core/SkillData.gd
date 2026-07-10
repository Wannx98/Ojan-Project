extends Resource
class_name SkillData

enum SkillType{
	MELEE,
	BUFF,
	PROJECTILE,
	AOE
}

@export var skill_type: SkillType
@export var id: String
@export var skill_name: String
@export_multiline
var description: String
@export var cooldown: float
@export var mana_cost: int
@export var damage: float
@export var cast_time: float
@export var range: float
@export var animation_prefix : String
@export var icon: Texture2D
@export var skill_scene: PackedScene

extends Resource
class_name SkillData

enum SkillType{
	MELEE,
	BUFF,
	PROJECTILE,
	AOE
}
#Identity
@export var skill_type: SkillType
@export var id: String
@export var skill_name: String
@export_multiline var description: String
#Stats
@export var cooldown: float
@export var mana_cost: int
@export var damage: float
@export var cast_time: float
@export var range: float
@export var knockback: float = 0
@export var stun_time: float = 0
@export var hitbox_size: Vector2 = Vector2(40,40)
@export var hitbox_offset: Vector2 = Vector2(30,0)
#etc
@export var animation_prefix : String
@export var icon: Texture2D
@export var skill_scene: PackedScene

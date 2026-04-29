extends CharacterBody2D
class_name Enemy

@export var enemy_id: String ="CapeMan"
@export var stats: EnemyStats

signal killed(enemy_id: String)

var hp: int = 0
var player: Node = null
var can_attack := true

func _ready():
	add_to_group("enemy")
	stats=stats
	print(stats)
	hp = stats.max_hp
	
	#regist all enemy

	if Quest_Manager:
		Quest_Manager.register_enemy(self)

	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("⚠️ Player tidak ditemukan! Tambahkan Player ke group 'player'")


func _physics_process(delta):
	if player == null or not is_instance_valid(player):
		return

	var distance = global_position.distance_to(player.global_position)

	if distance > stats.attack_range:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * stats.movement_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		attack_player()


func attack_player():
	if not can_attack:
		return
	if player == null or not is_instance_valid(player):
		return

	player.take_damage(stats.attack)
	print("🗡️ Enemy attack player:",stats.attack)

	can_attack = false
	await get_tree().create_timer(stats.attack_cooldown).timeout
	can_attack = true


func take_damage(amount: int):
	hp -= amount
	print("💥 Enemy kena hit:", amount, "| Sisa HP =", hp)

	if hp <= 0:
		print("☠️ Enemy mati")
		emit_signal("killed", enemy_id)
		queue_free()

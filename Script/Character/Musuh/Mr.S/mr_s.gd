extends CharacterBody2D
class_name Boss

enum BossState { NORMAL, RAGE }

@export var enemy_id: String = "Mr.S"
@export var stats: EnemyStats

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attackbox: Area2D = $Attackbox

signal killed(enemy_id: String)

# ======================
# STATE
# ======================
var current_state: BossState = BossState.NORMAL
var is_dead := false

# ======================
# STATS (RUNTIME)
# ======================
var hp: int
var current_attack: float
var current_speed: float
var current_cooldown: float

# ======================
# OTHER
# ======================
var player: Node2D
var can_attack := true
var is_attacking := false
var last_facing_dir := Vector2.DOWN

# ======================
# READY
# ======================
func _ready():
	add_to_group("enemy")
	print("==== BOSS MRS ====")
	print("ID:", enemy_id)
	print("HP:", stats.max_hp)
	print("ATK:", stats.attack)
	print("DEF:", stats.defense)
	print("SPD:", stats.movement_speed)
	print("RANGE:", stats.attack_range)
	print("CD:", stats.attack_cooldown)
	print("RESOURCE ID:", stats.get_instance_id())
	print("===================")

	# 🔥 duplicate biar gak shared
	stats = stats.duplicate()

	# 🔥 INIT RUNTIME STATS
	hp = stats.max_hp
	current_attack = stats.attack
	current_speed = stats.movement_speed
	current_cooldown = stats.attack_cooldown

	if Quest_Manager:
		Quest_Manager.register_enemy(self)

	player = get_tree().get_first_node_in_group("player")

	attackbox.monitoring = false
	attackbox.get_node("CollisionShape2D").disabled = true

	sprite.animation_finished.connect(_on_attack_animation_finished)

# ======================
# AI LOOP
# ======================
func _physics_process(delta):
	if is_dead:
		return

	if player == null or not is_instance_valid(player):
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	match current_state:
		BossState.NORMAL:
			_normal_behavior()
		BossState.RAGE:
			_rage_behavior()

# ======================
# BEHAVIOR
# ======================
func _normal_behavior():
	var dist = global_position.distance_to(player.global_position)

	if dist > stats.attack_range:
		_chase_player()
	else:
		_attack_player()

func _rage_behavior():
	var dist = global_position.distance_to(player.global_position)

	if dist > stats.attack_range:
		_chase_player()
	else:
		_attack_player()

# ======================
# MOVE
# ======================
func _chase_player():
	var dir = (player.global_position - global_position).normalized()
	last_facing_dir = dir
	velocity = dir * current_speed
	move_and_slide()
	_play_move_anim(dir)

# ======================
# ATTACK
# ======================
func _attack_player():
	if not can_attack:
		return

	can_attack = false
	is_attacking = true

	_play_attack_anim(last_facing_dir)
	_update_attackbox_position(last_facing_dir)
	_activate_hitbox()

	await get_tree().create_timer(current_cooldown).timeout
	can_attack = true

func _activate_hitbox():
	attackbox.monitoring = true
	attackbox.get_node("CollisionShape2D").disabled = false

	await get_tree().create_timer(0.15).timeout

	attackbox.monitoring = false
	attackbox.get_node("CollisionShape2D").disabled = true

# ======================
# ANIMATION
# ======================
func _play_move_anim(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		sprite.animation = "right" if dir.x > 0 else "left"
	else:
		sprite.animation = "down" if dir.y > 0 else "up"
	sprite.play()

func _play_attack_anim(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		sprite.animation = "atk_right" if dir.x > 0 else "atk_left"
	else:
		sprite.animation = "atk_down" if dir.y > 0 else "atk_up"
	sprite.play()

func _on_attack_animation_finished():
	if sprite.animation.begins_with("atk_"):
		is_attacking = false
		sprite.play("idle")

# ======================
# HITBOX
# ======================
func _update_attackbox_position(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		attackbox.position = Vector2(30 * sign(dir.x), 0)
	else:
		attackbox.position = Vector2(0, 30 * sign(dir.y))

func _on_attackbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_attacking:
		body.take_damage(current_attack)
		print("💥 Boss hit player:", current_attack)

# ======================
# DAMAGE
# ======================
func take_damage(amount: int):
	if is_dead:
		return

	hp -= amount
	print("💥 Boss hit:", amount, "| HP:", hp)

	# 🔥 DEATH PRIORITY
	if hp <= 0:
		is_dead = true
		emit_signal("killed", enemy_id)
		queue_free()
		return

	# 🔥 PHASE CHANGE
	if hp < stats.max_hp * 0.5 and current_state != BossState.RAGE:
		current_state = BossState.RAGE
		_enter_rage_mode()

# ======================
# RAGE MODE
# ======================
func _enter_rage_mode():
	print("🔥 BOSS RAGE MODE")

	current_speed *= 1.5
	current_attack *= 1.5
	current_cooldown *= 0.7

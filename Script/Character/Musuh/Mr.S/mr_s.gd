extends CharacterBody2D
class_name Boss

@export var enemy_id: String ="Mr.S"
@export var stats: EnemyStats

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attackbox: Area2D = $Attackbox

signal killed(enemy_id: String)

var hp := 0
var player: Node2D
var can_attack := true
var is_attacking := false
var last_facing_dir := Vector2.DOWN

func _ready():
	add_to_group("enemy")
	hp = stats.max_hp
	
	if Quest_Manager:
		Quest_Manager.register_enemy(self)

	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("⚠ Player not found")

	attackbox.monitoring = false
	attackbox.get_node("CollisionShape2D").disabled = true

	sprite.animation_finished.connect(_on_attack_animation_finished)

# ======================
# AI LOOP
# ======================
func _physics_process(delta):
	if player == null or not is_instance_valid(player):
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

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
	velocity = dir * stats.movement_speed
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

	await get_tree().create_timer(stats.attack_cooldown).timeout
	can_attack = true

func _activate_hitbox():
	$Attackbox.monitoring = true
	$Attackbox.get_node("CollisionShape2D").disabled = false

	await get_tree().create_timer(0.15).timeout

	$Attackbox.monitoring = false
	$Attackbox.get_node("CollisionShape2D").disabled = true

# ======================
# ANIMATION
# ======================
func _play_move_anim(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		$AnimatedSprite2D.animation = "right" if dir.x > 0 else "left"
	else:
		$AnimatedSprite2D.animation = "down" if dir.y > 0 else "up"
	$AnimatedSprite2D.play()

func _play_attack_anim(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		$AnimatedSprite2D.animation = "atk_right" if dir.x > 0 else "atk_left"
	else:
		$AnimatedSprite2D.animation = "atk_down" if dir.y > 0 else "atk_up"
	$AnimatedSprite2D.play()

func _on_attack_animation_finished():
	if $AnimatedSprite2D.animation.begins_with("atk_"):
		is_attacking = false
		$AnimatedSprite2D.play("idle")

# ======================
# HITBOX
# ======================
func _update_attackbox_position(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		$Attackbox.position = Vector2(30 * sign(dir.x), 0)
	else:
		$Attackbox.position = Vector2(0, 30 * sign(dir.y))

func _on_attackbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_attacking:
		body.take_damage(stats.attack)
		print("💥 Boss hit player:", stats.attack)
		

# ======================
# DAMAGE
# ======================
func take_damage(amount: int):
	hp -= amount
	print("💥 Boss hit:", amount, "| HP:", hp)

	if hp <= 0:
		emit_signal("killed", enemy_id)
		queue_free()

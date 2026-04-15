extends CharacterBody2D

# ===========================
# EXPORT & VARIABLES
# ===========================
@export var player_stats: PlayerStats
@export var inventory: PlayerInventory

var is_attacking = false
var attack_dir := Vector2.ZERO
var attack_cooldown := 0.35
var last_facing_dir := Vector2.DOWN

# ===========================
# SIGNALS
# ===========================
signal stats_changed
signal inventory_changed

# ===========================
# READY
# ===========================
func _ready():
	$Hitbox.monitoring = false
	$Hitbox.visible = false

	connect("stats_changed", Callable(self, "_on_stats_changed"))
	$AnimatedSprite2D.animation_finished.connect(_on_attack_animation_finished)

	if player_stats == null:
		player_stats = PlayerStats.new()
		print("⚠ player_stats auto-created")

	if inventory == null:
		inventory = PlayerInventory.new()
		print("⚠ inventory auto-created")

	debug_stats()

# ===========================
# INPUT
# ===========================
func _input(event):
	if event.is_action_pressed("debug_inv"):
		debug_inventory()

# ===========================
# MOVEMENT & CORE LOOP
# ===========================
func _physics_process(delta):
	var dir = Vector2.ZERO

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_hitbox_position()
		return

	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	dir = dir.normalized()

	velocity = dir * player_stats.get_stat("movement_speed")
	move_and_slide()

	if dir != Vector2.ZERO:
		last_facing_dir = dir

	_update_animation(dir)
	_update_hitbox_position()

	if Input.is_action_just_pressed("Attack"):
		attack(dir)

# ===========================
# ANIMATION
# ===========================
func _update_animation(dir: Vector2):
	if is_attacking:
		return

	if dir == Vector2.ZERO:
		_play_idle_directional()
		return

	if abs(dir.x) > abs(dir.y):
		$AnimatedSprite2D.animation = "right" if dir.x > 0 else "left"
	else:
		$AnimatedSprite2D.animation = "down" if dir.y > 0 else "up"

	$AnimatedSprite2D.play()

func _play_idle_directional():
	if abs(last_facing_dir.x) > abs(last_facing_dir.y):
		$AnimatedSprite2D.animation = "idle_right" if last_facing_dir.x > 0 else "idle_left"
	else:
		$AnimatedSprite2D.animation = "idle_down" if last_facing_dir.y > 0 else "idle_up"

	$AnimatedSprite2D.play()

# ===========================
# ATTACK SYSTEM
# ===========================
func attack(dir: Vector2):
	if is_attacking:
		return

	is_attacking = true
	attack_dir = last_facing_dir if dir == Vector2.ZERO else dir

	if abs(attack_dir.x) > abs(attack_dir.y):
		$AnimatedSprite2D.animation = "atk_right" if attack_dir.x > 0 else "atk_left"
	else:
		$AnimatedSprite2D.animation = "atk_down" if attack_dir.y > 0 else "atk_up"

	$AnimatedSprite2D.play()

	_update_hitbox_position()
	activate_hitbox()

	await get_tree().create_timer(attack_cooldown).timeout
	is_attacking = false

func activate_hitbox():
	$Attackbox.monitoring = true
	$Attackbox.monitorable = true
	$Attackbox.get_node("CollisionShape2D").disabled = false

	await get_tree().create_timer(0.15).timeout

	$Attackbox.monitoring = false
	$Attackbox.monitorable = false
	$Attackbox.get_node("CollisionShape2D").disabled = true

func _update_hitbox_position():
	var d = attack_dir if is_attacking else last_facing_dir

	if abs(d.x) > abs(d.y):
		$Attackbox.position = Vector2(25 * sign(d.x), 0)
	else:
		$Attackbox.position = Vector2(0, 25 * sign(d.y))

func _on_attack_animation_finished():
	if $AnimatedSprite2D.animation.begins_with("atk_"):
		is_attacking = false
		_play_idle_directional()  # 🔥 FIX DI SINI

# ===========================
# DAMAGE SYSTEM
# ===========================
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and is_attacking:
		var dmg = player_stats.get_stat("base_attack")
		body.take_damage(dmg)

func take_damage(amount: float):
	var defense = player_stats.get_stat("base_defense")
	var final_damage = max(1, amount - defense)

	player_stats.health -= final_damage
	player_stats.health = clamp(player_stats.health, 0, player_stats.max_health)

	print("Player took", final_damage, "damage!")
	emit_signal("stats_changed")

	if player_stats.health <= 0:
		_on_player_died()

func _on_player_died():
	print("Player defeated!")
	$AnimatedSprite2D.play("dead")
	set_physics_process(false)

# ===========================
# INVENTORY SYSTEM
# ===========================
func add_item_to_inventory(item_id: String, amount: int = 1):
	if inventory == null:
		print("⚠ Inventory null")
		return false

	var success = inventory.add_item(item_id, amount)

	if success:
		print("Item added:", item_id, "x", amount)
		emit_signal("inventory_changed")
	else:
		print("⚠ Inventory full")

	return success

func debug_inventory():
	if inventory:
		for i in inventory.slots.size():
			var s = inventory.slots[i]
			if s:
				print("Slot", i, ":", s.item, "x", s.amount)
			else:
				print("Slot", i, ": (kosong)")
	else:
		print("Inventory null")

# ===========================
# ITEM USAGE
# ===========================
func use_item(item):
	if item == null:
		return

	match item.item_type:
		"consumable":
			_use_consumable(item)
		"equipment":
			_equip_item(item)

func _use_consumable(item):
	if item.has("heal"):
		player_stats.health = min(player_stats.max_health, player_stats.health + item.heal)

	if item.has("temp_attack"):
		player_stats.apply_modifier("temp_buff", {"base_attack": item.temp_attack})
		emit_signal("stats_changed")

		var t = get_tree().create_timer(10)
		t.timeout.connect(func():
			player_stats.remove_modifier("temp_buff")
			emit_signal("stats_changed")
		)

	print("Used:", item.display_name)
	emit_signal("stats_changed")

func _equip_item(item):
	var slot_id = item.slot
	player_stats.remove_modifier(slot_id)
	player_stats.apply_modifier(slot_id, item.stat_modifiers)

	print("Equipped:", item.display_name)
	emit_signal("stats_changed")

# ===========================
# UI & DEBUG
# ===========================
@onready var hp_bar = $"../CanvasLayer/HUD/HP bar"

func _on_stats_changed():
	debug_stats()
	_update_hp_bar()

func _update_hp_bar():
	if hp_bar:
		hp_bar.max_value = player_stats.max_health
		hp_bar.value = player_stats.health

func debug_stats():
	if player_stats:
		print("HP:", player_stats.health)
		print("ATK:", player_stats.get_stat("base_attack"))
		print("DEF:", player_stats.get_stat("base_defense"))
		print("---")

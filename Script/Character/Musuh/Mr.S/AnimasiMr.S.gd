extends AnimatedSprite2D

var is_attacking := false  # nanti di-set dari script Player utama

func _update_animation(dir: Vector2):
	# ❗ JANGAN GANGGU ANIM KALAU LAGI ATTACK
	if is_attacking:
		return

	if dir == Vector2.ZERO:
		stop()
		return
	
	play()

	# Tentukan animasi dari arah terbesar (left/right vs up/down)
	if abs(dir.x) > abs(dir.y):
		animation = "right" if dir.x > 0 else "left"
	else:
		animation = "down" if dir.y > 0 else "up"

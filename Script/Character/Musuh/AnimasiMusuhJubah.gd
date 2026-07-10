extends AnimatedSprite2D
func _update_animation(dir: Vector2):
	if dir == Vector2.ZERO:
		stop()
		return

	play()

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			animation = "right"
		else:
			animation = "left"
	else:
		if dir.y > 0:
			animation = "down"
		else:
			animation = "up"

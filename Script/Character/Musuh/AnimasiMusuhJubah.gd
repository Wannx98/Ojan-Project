extends AnimatedSprite2D
func _update_animation(dir: Vector2):
	if dir == Vector2.ZERO:
		$AnimatedSprite2D.stop()
		return
	
	$AnimatedSprite2D.play()

	# Tentukan animasi dari arah terbesar (left/right vs up/down)
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			$AnimatedSprite2D.animation = "right"
		else:
			$AnimatedSprite2D.animation = "left"
	else:
		if dir.y > 0:
			$AnimatedSprite2D.animation = "down"
		else:
			$AnimatedSprite2D.animation = "up"

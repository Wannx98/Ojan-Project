extends BaseSkill
class_name Mr_DropSword

func cast(user, skill):
	super.cast(user, skill)

	skill_owner.is_attacking = true

	var anim = skill.animation_prefix
	var dir = skill_owner.last_facing_dir

	if abs(dir.x) > abs(dir.y):
		anim += "_right" if dir.x > 0 else "_left"
	else:
		anim += "_down" if dir.y > 0 else "_up"

	skill_owner.sprite.play(anim)

	await get_tree().create_timer(0.25).timeout

	skill_owner.activate_attack_hitbox(skill.damage)

	await skill_owner.sprite.animation_finished

	skill_owner.is_attacking = false

	queue_free()

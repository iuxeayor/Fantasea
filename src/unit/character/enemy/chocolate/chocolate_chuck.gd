extends Enemy

var disabled: bool = true:
	set(v):
		disabled = v
		if disabled:
			hitbox.disabled = true
			hurtbox.disabled = true
			gravity = 0
			velocity = Vector2.ZERO
			behavior_tree.disabled = true
		else:
			hitbox.disabled = false
			hurtbox.disabled = false
			gravity = Constant.gravity
			behavior_tree.disabled = false

func _ready() -> void:
	super ()
	disabled = true

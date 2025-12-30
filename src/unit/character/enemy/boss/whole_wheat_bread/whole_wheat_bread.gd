extends Boss

@onready var action_timer: Timer = $ActionTimer

func _ready() -> void:
	super()
	gravity = 0
	set_physics_process(false)
	UIManager.status_panel.boss_health_bar_container.update_separator([] as Array[int])

func start_battle() -> void:
	action_timer.start(randf_range(1, 2))
	super()

func hurt(damage: int) -> void:
	super(damage)
	if status.health <= 0:
		stop_battle()
		action_timer.stop()
		defeated.emit()

func _on_action_timer_timeout() -> void:
	if status.health > 0:
		sprite_2d.frame = randi_range(0, 3)
		action_timer.start(randf_range(1, 2))

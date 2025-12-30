extends Control

const DELAY: float = 0.01

var needed_resources: Array[String] = [
	"res://src/asset/particle/big_box.tres",
	"res://src/asset/particle/big_bullet_disappear.tres",
	"res://src/asset/particle/big_burger_land.tres",
	"res://src/asset/particle/big_enemy_hit.tres",
	"res://src/asset/particle/big_explosion.tres",
	"res://src/asset/particle/big_ice_bullet_trail.tres",
	"res://src/asset/particle/big_mushroom_ground_hit.tres",
	"res://src/asset/particle/big_mushroom_hurt.tres",
	"res://src/asset/particle/big_mushroom_land.tres",
	"res://src/asset/particle/big_mushroom_left_hit.tres",
	"res://src/asset/particle/big_mushroom_right_hit.tres",
	"res://src/asset/particle/big_peanut_butter_bullet_disappear.tres",
	"res://src/asset/particle/breakable_object_hit.tres",
	"res://src/asset/particle/butter_dash.tres",
	"res://src/asset/particle/butter_drop.tres",
	"res://src/asset/particle/charcoal_bullet.tres",
	"res://src/asset/particle/cola_bullet.tres",
	"res://src/asset/particle/defeat.tres",
	"res://src/asset/particle/enemy_hit.tres",
	"res://src/asset/particle/explosion.tres",
	"res://src/asset/particle/fires_charge.tres",
	"res://src/asset/particle/fire_bullet_smoke.tres",
	"res://src/asset/particle/fire_bullet_start.tres",
	"res://src/asset/particle/glass.tres",
	"res://src/asset/particle/high_snow.tres",
	"res://src/asset/particle/ice_bullet_disappear.tres",
	"res://src/asset/particle/ice_bullet_trail.tres",
	"res://src/asset/particle/ice_charge.tres",
	"res://src/asset/particle/ice_cream_bullet_disappear.tres",
	"res://src/asset/particle/ice_maker.tres",
	"res://src/asset/particle/ice_npc_charge.tres",
	"res://src/asset/particle/ice_platform.tres",
	"res://src/asset/particle/jelly_hit.tres",
	"res://src/asset/particle/jelly_land.tres",
	"res://src/asset/particle/low_snow.tres",
	"res://src/asset/particle/mid_bullet_disappear.tres",
	"res://src/asset/particle/pickle_break.tres",
	"res://src/asset/particle/player_dash.tres",
	"res://src/asset/particle/player_dead.tres",
	"res://src/asset/particle/player_double_jump.tres",
	"res://src/asset/particle/player_frozen_shield.tres",
	"res://src/asset/particle/player_hit_wall.tres",
	"res://src/asset/particle/player_hurt.tres",
	"res://src/asset/particle/player_wall_slide.tres",
	"res://src/asset/particle/rain.tres",
	"res://src/asset/particle/roll_gun_smoke.tres",
	"res://src/asset/particle/roll_shock_bullet.tres",
	"res://src/asset/particle/roll_teleport.tres",
	"res://src/asset/particle/save_point.tres",
	"res://src/asset/particle/seed_hit.tres",
	"res://src/asset/particle/skewer_hit_wall.tres",
	"res://src/asset/particle/small_bullet_disappear.tres",
	"res://src/asset/particle/smoke.tres",
	"res://src/asset/particle/watermelon_hit_wall.tres",
	"res://src/asset/particle/watermelon_land.tres",
	"res://src/asset/particle/watermelon_roll.tres",
	"res://src/asset/particle/water_drop_particle.tres",
	"res://src/asset/particle/wind_snow.tres",
	"res://src/asset/shader/blur.gdshader",
	"res://src/asset/shader/crt.gdshader",
	"res://src/asset/shader/grayscale.gdshader",
	"res://src/asset/shader/hurt_flash.gdshader",
	"res://src/asset/shader/outline.gdshader"
]

var waiting: bool = false

@onready var loading_label: Label = $Black/VBoxContainer/LoadingLabel
@onready var loading_progress: ProgressBar = $Black/VBoxContainer/LoadingProgress
@onready var resource_node: Node2D = $ResourceNode
@onready var press_hint: Label = $Black/VBoxContainer/PressHint
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	Game.is_debugging = false
	press_hint.modulate.a = 0
	UIManager.touchscreen.hide()
	Config.load_config()
	await get_tree().create_timer(0.1).timeout
	if Util.is_web_platform(): # web平台有单独的加载方案
		loading_label.hide()
		loading_progress.hide()
		animation_player.play("hinting")
		waiting = true
		return
	await _load_resource()
	await get_tree().create_timer(0.1).timeout
	if Util.is_has_save_file():
		get_tree().change_scene_to_file("res://src/ui/title_screen.tscn")
	else:
		animation_player.play("hinting")
		waiting = true

func _input(event: InputEvent) -> void:
	if not waiting:
		return
	# 按下按键触发
	if (event is InputEventKey
		or event is InputEventMouseButton
		or event is InputEventJoypadButton
		or event is InputEventScreenTouch):
		waiting = false
		get_viewport().set_input_as_handled()
		if Util.is_has_save_file():
			get_tree().change_scene_to_file("res://src/ui/title_screen.tscn")
		else:
			Game.start_game()
	
func _load_resource() -> void:
	# 切分进度条，起始和结束会各使用一格，防止卡在0和100
	var progress_split: float = 100.0 / (needed_resources.size() + 2)
	# 进度条动第一格
	var tween_start: Tween = create_tween()
	tween_start.tween_property(loading_progress, "value", progress_split, DELAY)
	await tween_start.finished
	for idx: int in needed_resources.size():
		var resource: Resource = load(needed_resources[idx])
		if resource is Shader: # Shader使用ColorRect加载
			var temp: ColorRect = ColorRect.new()
			temp.size = Vector2.ONE
			temp.material = ShaderMaterial.new()
			temp.material.shader = resource
			resource_node.add_child(temp)
		elif resource is ParticleProcessMaterial: # ParticleProcessMaterial使用GPUParticles2D来加载
			var temp: GPUParticles2D = GPUParticles2D.new()
			temp.process_material = resource
			resource_node.add_child(temp)
		# 暂无其它资源，直接跳过
		# 播放进度条动画
		var tween: Tween = create_tween()
		tween.tween_property(loading_progress, "value", progress_split * (idx + 2), DELAY)
		await tween.finished
	var tween_end: Tween = create_tween()
	tween_end.tween_property(loading_progress, "value", 100, DELAY)
	await tween_end.finished

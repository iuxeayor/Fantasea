extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var music_tween: Tween = null
var original_music_volume: float = 1.0
var music_volume: float = 1.0:
	set(v):
		music_volume = v
		if not is_node_ready():
			return
		SoundManager.set_volume(Constant.Bus.BGM, v)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		Engine.time_scale = 6
	elif event.is_action_released("ui_accept"):
		Engine.time_scale = 1

func _ready() -> void:
	original_music_volume = SoundManager.get_volume(Constant.Bus.BGM)
	music_volume = original_music_volume
	Achievement.set_achievement(Achievement.ID.STORY_END)
	UIManager.status_panel.hide()
	UIManager.special_effect.cover_in()
	Engine.time_scale = 1
	SoundManager.play_bgm(preload("res://asset/music/end.ogg"))
	UIManager.special_effect.fade_out(0)
	UIManager.special_effect.movie_out(0)
	UIManager.special_effect.cover_out()
	animation_player.play("end")
	
func _exit_tree() -> void:
	if music_tween != null and music_tween.is_running():
		music_tween.kill()
	Engine.time_scale = Config.game_speed
	SoundManager.set_volume.call_deferred(Constant.Bus.BGM, original_music_volume)

func _on_button_icon_pressed() -> void:
	OS.shell_open("https://fonts.google.com/icons")

func _on_button_music_pressed() -> void:
	OS.shell_open("https://tallbeard.itch.io/")


func _on_button_music_2_pressed() -> void:
	OS.shell_open("https://alkakrab.itch.io/")


func _on_button_sfx_pressed() -> void:
	OS.shell_open("https://leohpaz.itch.io/")


func _on_button_sfx_2_pressed() -> void:
	OS.shell_open("https://gameburp.itch.io/")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	music_tween = create_tween()
	music_tween.tween_property(self, "music_volume", 0, 3)
	await UIManager.special_effect.fade_in(3)
	get_tree().change_scene_to_file("res://src/ui/title_screen.tscn")

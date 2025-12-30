extends Node

@onready var movie: CanvasLayer = $Movie
@onready var top_movie_mask: ColorRect = $Movie/TopMovieMask
@onready var bottom_movie_mask: ColorRect = $Movie/BottomMovieMask

@onready var fade: CanvasLayer = $Fade
@onready var fade_mask: ColorRect = $Fade/FadeMask

@onready var cover: CanvasLayer = $Cover

@onready var filter: CanvasLayer = $Filter
@onready var crt_mask: ColorRect = $Filter/CRTMask
@onready var grayscale_mask: ColorRect = $Filter/GrayscaleMask


func _ready() -> void:
	_switch_filter("screen_filter")
	Config.config_changed.connect(_switch_filter)
	filter.layer = 1025 # PopMenu显示问题，https://shaggydev.com/2025/04/09/godot-ui-postprocessing-shaders/


func movie_in(time: float) -> void:
	movie.show()
	if time <= 0:
		top_movie_mask.position.y = 0
		bottom_movie_mask.position.y = 184
		return
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.tween_property(top_movie_mask, "position:y", 0, time)
	tween.tween_property(bottom_movie_mask, "position:y", 184, time)
	await tween.finished

func movie_out(time: float) -> void:
	if time <= 0:
		top_movie_mask.position.y = -32
		bottom_movie_mask.position.y = 216
		movie.hide()
		return
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.tween_property(top_movie_mask, "position:y", -32, time)
	tween.tween_property(bottom_movie_mask, "position:y", 216, time)
	await tween.finished
	movie.hide()

func fade_in(time: float) -> void:
	fade.show()
	if time <= 0:
		fade_mask.color.a = 1
		return
	fade_mask.color.a = 0
	var tween: Tween = create_tween()
	tween.tween_property(fade_mask, "color:a", 1, time)
	await tween.finished

func fade_out(time: float) -> void:
	if time <= 0:
		fade_mask.color.a = 0
		fade.hide()
		return
	var tween: Tween = create_tween()
	fade_mask.color.a = 1
	tween.tween_property(fade_mask, "color:a", 0, time)
	await tween.finished
	fade.hide()

func cover_in() -> void:
	cover.show()

func cover_out() -> void:
	cover.hide()


func _switch_filter(config_name: StringName) -> void:
	if config_name != "screen_filter":
		return
	match Config.screen_filter:
		Config.ScreenFilter.NONE:
			crt_mask.hide()
			grayscale_mask.hide()
		Config.ScreenFilter.CRT:
			crt_mask.show()
			grayscale_mask.hide()
		Config.ScreenFilter.GRAYSCALE:
			crt_mask.hide()
			grayscale_mask.show()

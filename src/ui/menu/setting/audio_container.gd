extends MenuContainer

@onready var master_slider: HSlider = $ContentContainer/GridContainer/MasterSlider
@onready var master_number: Label = $ContentContainer/GridContainer/MasterNumber
@onready var sfx_slider: HSlider = $ContentContainer/GridContainer/SFXSlider
@onready var sfx_number: Label = $ContentContainer/GridContainer/SFXNumber
@onready var bgm_slider: HSlider = $ContentContainer/GridContainer/BGMSlider
@onready var bgm_number: Label = $ContentContainer/GridContainer/BGMNumber


func refresh() -> void:
	master_slider.value = Config.master_volume * 100
	sfx_slider.value = Config.sfx_volume * 100
	bgm_slider.value = Config.bgm_volume * 100


func _on_master_slider_value_changed(value: float) -> void:
	master_number.text = "%3d%%" % value
	Config.master_volume = value / 100

func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_number.text = "%3d%%" % value
	Config.sfx_volume = value / 100

func _on_bgm_slider_value_changed(value: float) -> void:
	bgm_number.text = "%3d%%" % value
	Config.bgm_volume = value / 100

func _on_master_slider_focus_entered() -> void:
	change_message("SET_AUDIO_MASTER_DESC")

func _on_sfx_slider_focus_entered() -> void:
	change_message("SET_AUDIO_SFX_DESC")

func _on_bgm_slider_focus_entered() -> void:
	change_message("SET_AUDIO_BGM_DESC")


func _on_visibility_changed() -> void:
	master_slider.value = Config.master_volume * 100
	sfx_slider.value = Config.sfx_volume * 100
	bgm_slider.value = Config.bgm_volume * 100

extends MenuContainer

@onready var speed_slider: HSlider = $ContentContainer/GridContainer/SpeedContainer/SpeedSlider
@onready var speed_number: Label = $ContentContainer/GridContainer/SpeedContainer/SpeedNumber
@onready var easy_check: CheckButton = $ContentContainer/EasyCheck
@onready var auto_attack_check: CheckButton = $ContentContainer/AutoAttackCheck
@onready var close_shake_check: CheckButton = $ContentContainer/CloseShakeCheck

func refresh() -> void:
	speed_slider.value = Config.game_speed * 100
	easy_check.button_pressed = Config.easy_mode
	auto_attack_check.button_pressed = Config.auto_attack
	close_shake_check.button_pressed = Config.close_shake

func _on_speed_slider_value_changed(value: float) -> void:
	speed_number.text = "%3d%%" % value
	Config.game_speed = value / 100

func _on_speed_slider_focus_entered() -> void:
	change_message("SET_ASSIST_SPEED_DESC")

func _on_easy_check_focus_entered() -> void:
	change_message("SET_ASSIST_EASY_DESC")

func _on_easy_check_toggled(toggled_on: bool) -> void:
	Config.easy_mode = toggled_on

func _on_check_button_focus_entered() -> void:
	change_message("SET_ASSIST_AUTO_DESC")

func _on_check_button_toggled(toggled_on: bool) -> void:
	Config.auto_attack = toggled_on

func _on_close_shake_check_focus_entered() -> void:
	change_message("SET_ASSIST_CLOSE_SHAKE_DESC")

func _on_close_shake_check_toggled(toggled_on: bool) -> void:
	Config.close_shake = toggled_on

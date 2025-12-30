extends Control

var note_update_tween: Tween = null
var save_tween: Tween = null
var potion_store_tween: Tween = null
var device_tween: Tween = null

@onready var health_grid: HBoxContainer = $VBoxContainer/VBoxContainer/HBoxContainer/PanelContainer/HealthGrid
@onready var potion_info: HBoxContainer = $VBoxContainer/VBoxContainer/PotionInfo
@onready var potion_grid: HBoxContainer = $VBoxContainer/VBoxContainer/PotionInfo/PotionFrame/PotionGrid
@onready var potion_store_info: Label = $VBoxContainer/VBoxContainer/PotionInfo/PotionStoreInfo
@onready var money_count: Label = $VBoxContainer/MoneyContainer/Money
@onready var boss_health_bar_container: PanelContainer = $BossHealthBarContainer
@onready var note_update_hint: Label = $HintContainer/NoteUpdateHint
@onready var save_hint: Label = $HintContainer/SaveHint
@onready var device_hint: Label = $HintContainer/DeviceHint

func _ready() -> void:
	note_update_hint.hide()
	save_hint.hide()
	potion_store_info.hide()
	device_hint.hide()
	Status.saving.connect(display_saving)
	Status.saved.connect(display_saved)
	InputManager.device_changed.connect(display_device_changed)

func update_health(health: int, max_health: int) -> void:
	health_grid.change(health, max_health)

func update_potion(potion: int, max_potion: int) -> void:
	if max_potion <= 0:
		potion_info.hide()
	else:
		potion_info.show()
	potion_grid.change(potion, max_potion)
	
func update_money(money: int) -> void:
	money_count.update(money)

func update_boss_health(value: int, max_value: int) -> void:
	boss_health_bar_container.update_value(value, max_value)

func display_note_update() -> void:
	if note_update_tween != null and note_update_tween.is_running():
		note_update_tween.kill()
	note_update_hint.modulate.a = 1
	note_update_hint.show()
	note_update_tween = create_tween()
	note_update_tween.tween_property(note_update_hint, "modulate:a", 0, 2)
	note_update_tween.finished.connect(note_update_hint.hide, CONNECT_ONE_SHOT)

func update_potion_store_info(store: int, minus: int) -> void:
	if potion_store_tween != null:
		potion_store_tween.kill()
	potion_store_info.text = "%d(-%d)" % [store, minus]
	potion_store_info.show()
	potion_store_info.modulate.a = 1
	potion_store_tween = create_tween()
	potion_store_tween.tween_property(potion_store_info, "modulate:a", 0, 2)
	potion_store_tween.finished.connect(potion_store_info.hide, CONNECT_ONE_SHOT)

func display_saving() -> void:
	if save_tween != null and save_tween.is_running():
		save_tween.kill()
	save_hint.text = tr("SAVE_POINT_SAVING")
	save_hint.modulate.a = 1
	save_hint.show()

func display_saved(success: bool) -> void:
	if save_tween != null and save_tween.is_running():
		save_tween.kill()
	if success:
		save_hint.text = tr("SAVE_POINT_SAVED")
	else:
		save_hint.text = "Error"
	save_tween = create_tween()
	save_tween.tween_property(save_hint, "modulate:a", 0, 2)
	save_tween.finished.connect(save_hint.hide, CONNECT_ONE_SHOT)

func display_device_changed() -> void:
	var should_displayed: bool = false
	match InputManager.current_device:
		InputManager.Device.KEYBOARD_AND_MOUSE:
			device_hint.text = "Keyboard & Mouse"
			should_displayed = true
		InputManager.Device.JOYPAD:
			device_hint.text = "Xbox/PS/NS"
			should_displayed = true
	if should_displayed:
		device_hint.show()
		if device_tween != null and device_tween.is_running():
			device_tween.kill()
		device_hint.modulate.a = 1
		device_tween = create_tween()
		device_tween.tween_property(device_hint, "modulate:a", 0, 2)
		device_tween.finished.connect(device_hint.hide, CONNECT_ONE_SHOT)
	else:
		device_hint.hide()

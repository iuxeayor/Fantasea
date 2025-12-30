extends Control

var opening: bool = false:
	set(v):
		opening = v
		if opening:
			get_tree().paused = true
			item_icon.scale = Vector2(0, 0)
			message_label.visible_characters = 0
			return_button.disabled = true
			show()
			var tween: Tween = create_tween()
			tween.tween_property(item_icon, "scale", Vector2.ONE, 0.5)
			await tween.finished
			return_button.disabled = false
			return_button.grab_focus.call_deferred()
		else:
			animation_player.stop()
			hide()
			item_icon.scale = Vector2(0, 0)
			get_tree().paused = false

@onready var item_icon: TextureRect = $ItemIcon
@onready var message_label: RichTextLabel = $PanelContainer/VBoxContainer/MessageLabel
@onready var return_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/ReturnButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	return_button.disabled = true

func _unhandled_input(event: InputEvent) -> void:
	if opening:
		if event.is_action_pressed("ui_cancel"):
			if not return_button.disabled:
				if get_viewport().gui_get_focus_owner() == return_button:
					opening = false
				else:
					return_button.grab_focus.call_deferred()
				get_viewport().set_input_as_handled()

func update(texture: Texture2D, info: String) -> void:
	item_icon.texture = texture
	message_label.text = tr(info)
	animation_player.play("rotate")

func _on_return_button_pressed() -> void:
	Status.handle_achievement()
	opening = false


func _on_message_timer_timeout() -> void:
	if message_label.visible_characters < tr(message_label.text).length():
		message_label.visible_characters += 1

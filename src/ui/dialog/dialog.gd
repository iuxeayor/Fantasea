extends Node2D

signal closed
signal changed

@export var root_dialog: DialogContent = null ## 根对话
@export var hide_disabled: bool = false ## 隐藏而不是无效化未激活选项

var message_tween: Tween = null

var disabled: bool = true:
	set(v):
		disabled = v
		if is_node_ready():
			if disabled:
				SoundManager.play_sfx("DialogClose")
				message.visible_characters = 0
				next_button.disabled = true
				animation_player.play("close")
				await animation_player.animation_finished
				if current_dialog.can_release_control:
					InputManager.disabled = false
				# 对话会隐藏交互提示，处理重新显示逻辑
				if Game.get_player() != null:
					Game.get_player().handle_interact_hint()
				closed.emit()
			else:
				SoundManager.play_sfx("DialogOpen")
				InputManager.disabled = true
				_change_dialog(root_dialog)
				next_button.disabled = true
				message.visible_characters = 0
				# 隐藏交互提示
				if Game.get_player() != null:
					Game.get_player().interact_hint.hide()
				scale = Vector2(0, 0)
				show()
				var tween: Tween = create_tween()
				tween.tween_property(self, "scale", Vector2.ONE, 0.1)
var current_dialog: DialogContent = null # 当前的对话
var current_message_id: String = ""
var dialog_index: int = 0
var dialog_button: Resource = load("res://src/ui/dialog/dialog_button.tscn")


@onready var message: RichTextLabel = $Frame/Content/Message
@onready var options: VBoxContainer = $Frame/Content/Options
@onready var next_button: Button = $Frame/Content/NextButton
@onready var frame: PanelContainer = $Frame
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()
	Config.config_changed.connect(_handle_text)

func _unhandled_input(event: InputEvent) -> void:
	if disabled:
		return
	if ((event.is_action_pressed("interact")
		or event.is_action_pressed("jump"))
		and not event.is_echo()):
		# 逐字显示对话，按交互键或跳跃键直接显示全部
		if (message.visible_ratio < 1):
			if message_tween != null and message_tween.is_running():
				message_tween.kill()
			message.visible_ratio = 1
			_handle_message_end()
			get_viewport().set_input_as_handled()

func _handle_text(config_name: StringName) -> void:
	if config_name != "language":
		return
	message.text = tr(current_message_id)


# 切换对话信息
func _change_message(idx: int) -> void:
	# 清空选项
	for opt in options.get_children():
		opt.queue_free()
	next_button.disabled = true
	next_button.hide()
	# 切换到指定对话
	current_message_id = current_dialog.message[idx]
	message.text = tr(current_message_id)
	message.visible_characters = 0
	# 逐字显示对话
	if message_tween != null and message_tween.is_running():
		message_tween.kill()
	message_tween = create_tween()
	var time: float = max(message.text.length() / float(Util.get_char_per_second()), 0.1)
	message_tween.tween_property(message, "visible_ratio", 1, time)
	message_tween.finished.connect(_handle_message_end, CONNECT_ONE_SHOT)
	
# 切换对话
func _change_dialog(target: DialogContent) -> void:
	# 切换到指定对话
	current_dialog = target
	current_dialog.start()
	dialog_index = 0
	_change_message(dialog_index)
	if is_node_ready():
		changed.emit()

func _handle_message_end() -> void:
	if current_dialog == null:
		return
	if dialog_index < current_dialog.message.size() - 1:
		# 对话未结束，显示下一句
		next_button.disabled = false
		next_button.show()
		next_button.grab_focus.call_deferred()
		return
	await get_tree().create_timer(0.1).timeout
	if current_dialog.handled_target.size() > 0:
		# 有选项
		for target: DialogContent.Target in current_dialog.handled_target:
			var button: Button = dialog_button.instantiate()
			button.disabled = true
			button.button_disabled = target.disabled # 暂存按钮需要的状态，加载完毕后再设置
			button.text = tr(target.title)
			button.pressed.connect(_change_dialog.bind(target.dialog), CONNECT_ONE_SHOT)
			if hide_disabled and target.disabled:
				button.hide()
			options.add_child(button)
			if target.disabled and hide_disabled:
				continue
			await get_tree().create_timer(0.1).timeout
	if current_dialog.can_end:
		# 可以直接结束对话
		next_button.disabled = false
		next_button.show()
	else:
		# 不可结束对话
		next_button.disabled = true
		next_button.hide()
	# 设置按钮状态
	for btn: Button in options.get_children():
		btn.disabled = btn.button_disabled
	# focus第一个选项
	var has_valid_option: bool = false
	for opt in options.get_children():
		if not opt.disabled:
			opt.grab_focus.call_deferred()
			has_valid_option = true
			break
	# 没有可用选项，focus下一步按钮
	if not has_valid_option:
		next_button.grab_focus.call_deferred()

func _on_next_button_pressed() -> void:
	if current_dialog == null:
		return
	# 对话未结束，继续下一句
	if dialog_index < current_dialog.message.size() - 1:
		dialog_index += 1
		_change_message(dialog_index)
	# 对话结束
	elif dialog_index >= current_dialog.message.size() - 1:
		current_dialog.end()
		disabled = true

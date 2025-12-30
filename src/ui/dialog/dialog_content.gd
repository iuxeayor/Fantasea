extends Node
class_name DialogContent

signal started
signal ended

@export var can_end: bool = false ## 是否可以直接结束对话
@export var can_release_control: bool = true ## 是否可以直接释放操作，用于特殊对话
@export var message: Array[String] = [""] ## 完整信息
@export var target: Dictionary[String, DialogContent] = {} ## 跳转目标：按钮名字 -> 对话

var handled_target: Array[Target] = []

class Target:
	var id: String = ""
	var title: String = ""
	var dialog: DialogContent = null
	var disabled: bool = false

func _ready() -> void:
	for key: String in target.keys():
		var new_target: Target = Target.new()
		new_target.id = key
		new_target.title = key
		new_target.dialog = target.get(key)
		handled_target.append(new_target)

func get_target(id: String) -> Target:
	for tar: Target in handled_target:
		if tar.id == id:
			return tar
	return null

func start() -> void:
	started.emit()

func end() -> void:
	ended.emit()

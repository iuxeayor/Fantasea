extends Node2D
class_name ObjectPool

signal load_finished

class Request:
	var name: StringName
	var resource: Resource
	var count: int

var pools: Dictionary = {}

func _process(_delta: float) -> void:
	if Game.object_pool_request.size() == 0:
		load_finished.emit()
		set_process(false)
		return
	var req: Request = Game.object_pool_request.pop_front()
	for i in range(req.count):
		if req.resource == null:
			break
		var obj: Node = req.resource.instantiate()
		if not pools.has(req.name):
			pools[req.name] = []
		pools[req.name].append(obj)
		add_child.call_deferred(obj)

func get_object(obj_name: StringName) -> Node:
	if pools.has(obj_name):
		if pools[obj_name].size() > 0:
			return pools[obj_name].pop_front()
	return null

func recycle_object(obj_name: StringName, obj: Node) -> void:
	if not pools.has(obj_name):
		return
	if not pools[obj_name].has(obj):
		pools[obj_name].append(obj)

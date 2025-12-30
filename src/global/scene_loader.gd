extends Node

const SCENE_PATH: String = "res://src/scene/game/scene_%d.tscn"

var loading_scene: Dictionary[int, String] = {} # 正在加载的场景
var loaded_scene: Dictionary[int, PackedScene] = {} # 已加载的场景

func load_scene_request(used_scene_index: Array[int]) -> void:
	for scene_index: int in used_scene_index:
		var scene_path: String = SCENE_PATH % scene_index
		if ResourceLoader.load_threaded_request(scene_path, "PackedScene") != OK:
			return
		loading_scene[scene_index] = scene_path

func get_scene(scene_index: int) -> PackedScene:
	if loaded_scene.has(scene_index):
		return loaded_scene[scene_index]
	if loading_scene.has(scene_index):
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(loading_scene[scene_index])
		if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var resource: PackedScene = ResourceLoader.load_threaded_get(loading_scene[scene_index])
			loading_scene.erase(scene_index)
			loaded_scene[scene_index] = resource
			return resource
	return ResourceLoader.load(SCENE_PATH % scene_index, "PackedScene")

func remove_unused_scene(used_scene_index: Array[int]) -> void:
	for scene_index: int in loaded_scene.keys():
		if scene_index not in used_scene_index:
			loaded_scene.erase(scene_index)

# 周期性检查加载状态
func _on_timer_timeout() -> void:
	for scene_index: int in loading_scene.keys():
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(loading_scene[scene_index])
		if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var resource: PackedScene = ResourceLoader.load_threaded_get(loading_scene[scene_index])
			loading_scene.erase(scene_index)
			loaded_scene[scene_index] = resource

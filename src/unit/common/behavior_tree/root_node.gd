class_name RootNode
extends BehaviorTreeNode

# 根节点
## 负责管理整个行为树的生命周期

func _ready() -> void:
	super ()
	if child_nodes.size() >= 1:
		child_nodes[0]._enter()

func _physics_process(delta: float) -> void:
	if disabled:
		return
	# 根节点只能有一个子节点
	if child_nodes.size() != 1:
		print("[%s]%s has %d children, should have 1" % [Engine.get_frames_drawn(), get_name(), child_nodes.size()])
		return
	child_nodes[0].tick(delta)

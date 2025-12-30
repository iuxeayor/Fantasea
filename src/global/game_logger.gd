extends Node

var btree_depth: int = 0:
	set(v):
		btree_depth = max(0, v)

func btree_log(node_name: String, enter: bool) -> void:
	if not Game.is_debugging:
		return  
	var frame: int = Engine.get_frames_drawn()
	if enter:
		btree_depth += 1
		var line: String = "-".repeat(btree_depth)
		print("[%10d] %s> %s" % [frame, line, node_name])
	else:
		var line: String = "-".repeat(btree_depth)
		print("[%10d] <%s %s" % [frame, line, node_name])
		btree_depth -= 1
		

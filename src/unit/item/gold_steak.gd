extends Item

func _collect() -> void:
	super()
	for n: Node in get_tree().get_nodes_in_group("player_light"):
		if n is PointLight2D:
			n.show()
		

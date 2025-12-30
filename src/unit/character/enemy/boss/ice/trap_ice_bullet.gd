extends CharacterBullet

func spawn(location: Vector2, velo: Vector2) -> void:
	super (location, velo)

# 玩家在无敌情况也可以踩掉
func _on_player_checker_body_entered(body: Node2D) -> void:
	if body is Player:
		dead()

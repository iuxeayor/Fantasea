extends CharacterStatus
class_name PlayerCharacterStatus

var raw_attack: int = 0

var attack: int = 0:
	set(v):
		attack = max(0, v)
		emit_status_changed("attack", attack)

var max_potion: int = 0:
	set(v):
		max_potion = max(0, v)
		potion = min(potion, max_potion)
		emit_status_changed("max_potion", max_potion)

var potion: int = 0:
	set(v):
		potion = clampi(v, 0, max_potion)
		emit_status_changed("potion", potion)
		

var potion_store: int = 0:
	set(v):
		potion_store = max(0, v)
		emit_status_changed("potion_store", potion_store)

var money: int = 0:
	set(v):
		money = max(0, v)
		emit_status_changed("money", v)
		if money >= 100:
			Achievement.set_achievement(Achievement.ID.COLLECT_100_COINS)

func from_status(status: Status.PlayerStatus) -> void:
	raw_attack = Util.get_attack_power(status.number_collection.get("weapon_level", 0))
	attack = raw_attack
	max_health = Util.get_max_health(status.number_collection.get("health_chip", 0))
	max_potion = status.number_collection.get("potion", 0)
	# 玩家信息
	health = status.health
	potion = status.potion
	potion_store = status.potion_store
	money = status.money
	

func to_status() -> void:
	Status.player_status.health = health
	Status.player_status.potion = potion
	Status.player_status.money = money
	Status.player_status.potion_store = potion_store
	

func _on_status_changed(type_name: StringName, _value: Variant) -> void:
	if not is_node_ready():
		return
	match type_name:
		"health", "max_health":
			UIManager.status_panel.update_health(health, max_health)
			if Status.has_collection("silk_tofu"): # 道具补丁，代码设计有问题
				# 生命值满或只剩1时，攻击力+3
				if health == max_health or health == 1:
					attack = raw_attack + 3
				else:
					attack = raw_attack
		"potion", "max_potion":
			UIManager.status_panel.update_potion(potion, max_potion)
		"money":
			UIManager.status_panel.update_money(money)
			Status.player_status.money = money

extends HBoxContainer

var message_tween: Tween = null

var opening: bool = false:
	set(v):
		opening = v
		if opening:
			if Game.get_player() != null:
				update(Status.player_status)
			show()
			if is_node_ready():
				health.grab_focus()
		else:
			hide() 
			
@onready var message: RichTextLabel = $Message

@onready var health: ItemButton = $ItemContainer/HBoxContainer/Health
@onready var potion: ItemButton = $ItemContainer/HBoxContainer/Potion
@onready var money: ItemButton = $ItemContainer/HBoxContainer/Money
@onready var stick: Button = $ItemContainer/HBoxContainer/Stick
@onready var watermelon_seed: ItemButton = $ItemContainer/HBoxContainer/WatermelonSeed
@onready var jelly: ItemButton = $ItemContainer/HBoxContainer/Jelly

@onready var club_soda: ItemButton = $ItemContainer/SubItemContainer/ClubSoda
@onready var honey: ItemButton = $ItemContainer/SubItemContainer/Honey
@onready var gold_steak: ItemButton = $ItemContainer/SubItemContainer/GoldSteak
@onready var jelly_pouch: ItemButton = $ItemContainer/SubItemContainer/JellyPouch
@onready var bang_card: ItemButton = $ItemContainer/SubItemContainer/BangCard
@onready var chicken_sandwich: ItemButton = $ItemContainer/SubItemContainer/ChickenSandwich

@onready var want_more_milk: ItemButton = $ItemContainer/SubItemContainer/WantMoreMilk
@onready var magnet: ItemButton = $ItemContainer/SubItemContainer/Magnet
@onready var nutmeg: ItemButton = $ItemContainer/SubItemContainer/Nutmeg
@onready var mushroom_powder: ItemButton = $ItemContainer/SubItemContainer/MushroomPowder
@onready var sweet_jiuniang: ItemButton = $ItemContainer/SubItemContainer/SweetJiuniang
@onready var stinky_tofu: ItemButton = $ItemContainer/SubItemContainer/StinkyTofu

@onready var straw_glasses: ItemButton = $ItemContainer/SubItemContainer/StrawGlasses
@onready var fresh_milk: ItemButton = $ItemContainer/SubItemContainer/FreshMilk
@onready var frozen_apple: ItemButton = $ItemContainer/SubItemContainer/FrozenApple
@onready var hot_sauce: ItemButton = $ItemContainer/SubItemContainer/HotSauce
@onready var lemon_slice: ItemButton = $ItemContainer/SubItemContainer/LemonSlice
@onready var silk_tofu: ItemButton = $ItemContainer/SubItemContainer/SilkTofu

func _ready() -> void:
	for item_btn: ItemButton in get_tree().get_nodes_in_group("item_button"):
		item_btn.focus_entered.connect(_handle_focus_item_button.bind(item_btn))

func update(player_status: Status.PlayerStatus) -> void:
	# 生命：面粉
	health.info = tr("ITEM_FLOUR") % [
		Constant.HEALTH_CHIP_DIVISION,
		player_status.number_collection.get("health_chip", 0),
		Util.get_max_health(player_status.number_collection.get("health_chip", 0)) - Constant.BASE_HP,
		]
	health.collected = player_status.number_collection.get("health_chip", 0) > 0
	# 药水：牛奶
	potion.info = tr("ITEM_MILK") % [
		InputManager.action_to_text("heal"),
		player_status.number_collection.get("potion", 0),
		player_status.potion_store
		]
	potion.collected = player_status.number_collection.get("potion", 0) > 0
	# 钱：硬币
	money.info = tr("ITEM_COIN") % [
		player_status.money
		]
	money.collected = player_status.money > 0
	# 武器：棍子
	stick.update(player_status.number_collection.get("weapon_level", 0))
	stick.collected = player_status.number_collection.get("weapon_level", 0) > 0
	# 投掷物：西瓜种子
	watermelon_seed.info = tr("ITEM_WATERMELON_SEED") % [
		InputManager.action_to_text("shoot"),
		]
	watermelon_seed.collected = player_status.collection.get("watermelon_seed", false)
	# 投掷物：果冻
	jelly.info = tr("ITEM_JELLY") % [
		InputManager.action_to_text("throw")
	]
	jelly.collected = player_status.collection.get("jelly", false)

	# 气泡水
	club_soda.info = tr("ITEM_CLUB_SODA") % [
		InputManager.action_to_text("dash")
		]
	club_soda.collected = player_status.collection.get("club_soda", false)
	# 蜂蜜
	honey.collected = player_status.collection.get("honey", false)
	# 金箔牛排
	gold_steak.collected = player_status.collection.get("gold_steak", false)
	# 吸吸果冻
	jelly_pouch.collected = player_status.collection.get("jelly_pouch", false)
	# 棒乐园卡
	bang_card.collected = player_status.collection.get("bang_card", false)
	# 板烧鸡腿堡
	chicken_sandwich.collected = player_status.collection.get("chicken_sandwich", false)
	
	# 旺财牛奶
	want_more_milk.collected = player_status.collection.get("want_more_milk", false)
	# 磁铁
	magnet.collected = player_status.collection.get("magnet", false)
	# 肉豆蔻
	nutmeg.collected = player_status.collection.get("nutmeg", false)
	# 蘑菇粉
	mushroom_powder.collected = player_status.collection.get("mushroom_powder", false)
	# 甜酒酿
	sweet_jiuniang.collected = player_status.collection.get("sweet_jiuniang", false)
	# 臭豆腐
	stinky_tofu.collected = player_status.collection.get("stinky_tofu", false)
	# 吸管眼镜
	straw_glasses.collected = player_status.collection.get("straw_glasses", false)
	# 鲜奶
	fresh_milk.collected = player_status.collection.get("fresh_milk", false)
	# 冻苹果
	frozen_apple.collected = player_status.collection.get("frozen_apple", false)
	# 辣酱
	hot_sauce.collected = player_status.collection.get("hot_sauce", false)
	# 柠檬片
	lemon_slice.collected = player_status.collection.get("lemon_slice", false)
	# 嫩豆腐
	silk_tofu.collected = player_status.collection.get("silk_tofu", false)


func _handle_focus_item_button(item_btn: ItemButton) -> void:
	if not item_btn.collected:
		_change_description("???")
	else:
		_change_description(tr(item_btn.info))

func _change_description(info: String) -> void:
	if message.text == info:
		return
	message.text = info
	message.visible_characters = 0
	if message_tween != null and message_tween.is_running():
		message_tween.kill()
	message_tween = create_tween()
	var time: float = message.text.length() / float(Util.get_char_per_second())
	message_tween.tween_property(message, "visible_characters", message.text.length(), time)

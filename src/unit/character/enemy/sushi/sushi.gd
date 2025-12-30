extends Enemy

@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var seed_checker: Area2D = $Graphics/SeedChecker
@onready var counterattack_collision: CollisionShape2D = $Graphics/CounterattackChecker/CounterattackCollision
@onready var counterattack_checker: Area2D = $Graphics/CounterattackChecker
@onready var counter_solid_collision: CollisionShape2D = $Graphics/CounterSolidBody/CounterSolidCollision ## 用于击破西瓜籽

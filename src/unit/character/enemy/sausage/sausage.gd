extends Enemy

@onready var seek_checker: RayCast2D = $Graphics/SeekChecker
@onready var attack_checker: RayCast2D = $Graphics/AttackChecker
@onready var top_wall_checker: RayCast2D = $Graphics/TopWallChecker
@onready var mid_wall_checker: RayCast2D = $Graphics/MidWallChecker
@onready var bottom_wall_checker: RayCast2D = $Graphics/BottomWallChecker

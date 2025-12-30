@tool
extends Sprite2D

enum ContainerColor {
	BROWN,
	BLUE,
	GREEN,
	RED,
	WHITE,
	BLACK
}

@export var container_color: ContainerColor = ContainerColor.BROWN:
	set(v):
		container_color = v
		frame = v
		

extends StaticBody2D

class_name Wall

@export var type: Globals.Models = Globals.Models.WALL

func start(pos: Vector2) -> void:
	position = pos

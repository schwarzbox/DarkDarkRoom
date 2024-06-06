extends Node2D

signal enemy_died

func _ready() -> void:
	prints(name, "ready")

	var screen_size: Vector2 = get_viewport().size

	var size = $Sprite2D.texture.get_size()
	position.x = randf_range(size.x, screen_size.x - size.x)
	position.y = 0

func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Player")
	
	if players:
		position = lerp(position, players[0].get_global_position(), delta)
	
	#rotation += delta

func _on_area_2d_area_entered(_area: Area2D) -> void:
	emit_signal("enemy_died", self)

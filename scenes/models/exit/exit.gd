extends Area2D

class_name Exit


func start(pos: Vector2) -> void:
	position = pos



func _on_body_entered(body: Player):
	body.win()

extends Area2D

class_name Exit


func start(pos: Vector2) -> void:
	position = pos
	
	$Sprite2D.modulate = Globals.COLORS.BLACK

func _process(delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if !enemies:
		$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE

func _on_body_entered(body: Player):
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if !enemies:
		body.win()

extends Area2D

class_name Exit

var _target: Player

func start(pos: Vector2) -> void:
	position = pos

	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.modulate = Globals.COLORS.BLACK

func _process(delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if !enemies:
		$CollisionShape2D.set_deferred("disabled", false)
		$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE
	if _target:
		_target.position = lerp(_target.position, global_position, 0.1)

func _on_body_entered(body: Player):
	_target = body
	body.win()

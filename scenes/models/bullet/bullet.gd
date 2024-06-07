extends Node2D

var _force: int = 512
var _linear_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	prints(name, "ready")
	
	$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE

func _process(delta: float) -> void:
	# dump
	_linear_velocity -= _linear_velocity * delta

	# move
	position += _linear_velocity * delta

func start(pos: Vector2, other_vel: Vector2, dir: float) -> void:
	position = pos + Vector2(randi_range(-4, 4), randi_range(-4, 4))
	rotation = dir
	_linear_velocity = (other_vel + Vector2(_force, 0)).rotated(rotation)

func _on_area_2d_area_entered(area: Area2D) -> void:
	queue_free()
	
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()




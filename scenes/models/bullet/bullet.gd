extends AnimatableBody2D

class_name Bullet

signal bullet_removed

@export var type: Globals.Models = Globals.Models.BULLET

var _force: int = 1024
var _linear_velocity: Vector2 = Vector2.ZERO
var _died: bool = false

func _ready() -> void:
	prints(name, "ready")
	sync_to_physics = false

	$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE

func _process(delta: float) -> void:
	# dump
	_linear_velocity -= _linear_velocity * delta

	# move
	if not _died:
		var collision = move_and_collide(_linear_velocity * delta)
		# collide
		if collision:
			var collider = collision.get_collider()
			if is_instance_of(collider, Enemy):
				hit()
				collider.hit()
			if is_instance_of(collider, Wall):
				hit()

	# destroy
	if _linear_velocity.length_squared() < 16:
		queue_free()

func start(pos: Vector2, other_vel: Vector2, dir: float) -> void:
	position = pos + Vector2(randi_range(-4, 4), randi_range(-4, 4))
	rotation = dir
	_linear_velocity = (other_vel + Vector2(_force, 0)).rotated(rotation)

func hit() -> void:
	_died = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), Globals.SCALE_DOWN_DELAY)
	tween.tween_callback(
		func():
			emit_signal("bullet_removed")
			queue_free()
	)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()




extends AnimatableBody2D

class_name Enemy

signal enemy_died

@export var type: Globals.Models = Globals.Models.ENEMY

var sprite_size: Vector2

var _force: int = 128
var _torque: float = 2.5

var _linear_velocity: Vector2 = Vector2.ZERO
var _linear_acceleration: Vector2 = Vector2.ZERO
var _angular_velocity: float = 0
var _angular_acceleration: float = 0

var _died: bool = false
var _target: Player
var _closest: Dictionary = {}

static var _count: int = 0

func _ready() -> void:
	#prints(name, "ready")
	sync_to_physics = false

	add_to_group("Enemy")

	sprite_size = $Sprite2D.texture.get_size()
	$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH

	_count += 1
	#print_debug(_count)

func steer(value: Vector2, steer_force):
	var force = value.normalized() * _force - _linear_velocity
	return force.normalized() * steer_force

func _process(delta: float) -> void:
	# dump
	_linear_velocity -= _linear_velocity * delta
	_angular_velocity -= _angular_velocity * delta

	if _target:
		# use velocity
		var angle: float = global_position.angle_to_point(_target.get_global_position())
		rotation = lerp_angle(rotation, angle, 1.0)
		_linear_acceleration += Vector2(_force, 0).rotated(rotation)
	else:
		#_linear_acceleration += Vector2(_force, 0).rotated(rotation)
		#_angular_acceleration += randf_range(-PI, PI) * _torque
		var angle: float = randf_range(0, TAU)
		rotation = lerp_angle(rotation, angle, 1.0)
		_linear_acceleration += Vector2(_force, 0).rotated(rotation)

	_linear_velocity += _linear_acceleration * delta
	_angular_velocity += _angular_acceleration * delta

	# reset
	_linear_acceleration = Vector2()
	_angular_acceleration = 0

	# move
	# warning-ignore:return_value_discarded
	if !_died:
		var collision = move_and_collide(_linear_velocity * delta)
		if collision:
			var collider = collision.get_collider()
			if is_instance_of(collider, Wall):
				_linear_velocity = _linear_velocity.bounce(collision.get_normal())

	# rotate
	rotation += _angular_velocity * delta

func start(pos: Vector2) -> void:
	position = pos

func hit() -> void:
	if !_died:
		_died = true
		$AudioStreamPlayer2D.play()

		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0, 0), Globals.SCALE_DOWN_DELAY)
		tween.tween_callback(
			func():
				emit_signal("enemy_died", self)
				_count -= 1
		)
		#print_debug(_count)


func _on_target_range_body_entered(body: Player) -> void:
	# only Player
	_target = body


func _on_target_range_body_exited(_body: Player) -> void:
	# only Player
	_target = null


func _on_separation_range_body_entered(body: Enemy):
	if body != self:
		_closest[body.get_instance_id()] = body

func _on_separation_range_body_exited(body: Enemy):
	if body != self:
		_closest.erase(body.get_instance_id())


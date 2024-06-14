extends AnimatableBody2D

class_name Enemy

signal enemy_died

@export var type: Globals.Models = Globals.Models.ENEMY

var sprite_size: Vector2

var _force: int = 128
#var _torque: float = 2.5

var _linear_velocity: Vector2 = Vector2.ZERO
var _linear_acceleration: Vector2 = Vector2.ZERO

#var _angular_velocity: float = 0
#var _angular_acceleration: float = 0
var _died: bool = false
var _target: Player
var _closest: Dictionary = {}

static var _count: int = 0

func _ready() -> void:
	prints(name, "ready")
	sync_to_physics = false

	add_to_group("Enemy")
	
	sprite_size = $Sprite2D.texture.get_size()
	$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH
	
	_count += 1
	#print_debug(_count)

func steer(value: Vector2, steer_force):
	var steer = value.normalized() * _force - _linear_velocity
	return steer.normalized() * steer_force

func _process(delta: float) -> void:
	
	# dump
	_linear_velocity -= _linear_velocity * delta
	#_angular_velocity -= _angular_velocity * delta
	#var screen_size: Vector2 = get_viewport().size
	#var angle = global_position.angle_to_point(screen_size / 2)
	if _target:
		# use velocity
		var angle = global_position.angle_to_point(_target.get_global_position())
		# how to use _angular_velocity
		rotation = lerp_angle(rotation, angle, 1.0)
		_linear_acceleration += Vector2(_force, 0).rotated(rotation)
	else:
		var angle = randf_range(0, TAU)
		rotation = lerp_angle(rotation, angle, 1.0)
		_linear_acceleration += Vector2(_force, 0).rotated(rotation)

	_linear_velocity += _linear_acceleration * delta
	#_angular_velocity += _angular_acceleration * delta

#	reset
	_linear_acceleration = Vector2()
	#_angular_acceleration = 0

	# move
	# warning-ignore:return_value_discarded
	if not _died:
		move_and_collide(_linear_velocity * delta)

	# rotate
	#rotation += _angular_velocity * delta

func start(pos: Vector2) -> void:
	position = pos

func hit() -> void:
	_died = true
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


func _on_target_range_body_exited(body: Player) -> void:
	# only Player
	_target = null


func _on_separation_range_body_entered(body: Enemy):
	if body != self:
		_closest[body.get_instance_id()] = body

func _on_separation_range_body_exited(body: Enemy):
	if body != self:
		_closest.erase(body.get_instance_id())
	

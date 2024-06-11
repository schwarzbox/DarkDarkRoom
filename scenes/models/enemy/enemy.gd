extends AnimatableBody2D

class_name Enemy

signal enemy_died

@export var type: Globals.Models = Globals.Models.ENEMY

var _force: int = 256
#var _torque: float = 2.5

var _linear_velocity: Vector2 = Vector2.ZERO
var _linear_acceleration: Vector2 = Vector2.ZERO

#var _angular_velocity: float = 0
#var _angular_acceleration: float = 0

var _target: Player

static var _count: int = 0

func _ready() -> void:
	prints(name, "ready")
	sync_to_physics = false
	add_to_group("Enemy")

	$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH
	
	_count += 1
	#print_debug(_count)

func _process(delta: float) -> void:
	# dump
	_linear_velocity -= _linear_velocity * delta
	#_angular_velocity -= _angular_velocity * delta
	
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
	var collision = move_and_collide(_linear_velocity * delta)
	# collide
	if collision:
		var collider = collision.get_collider()
		if is_instance_of(collider, Enemy):
			_linear_velocity = _linear_velocity.bounce(collision.get_normal())
		
	# rotate
	#rotation += _angular_velocity * delta

func start(pos: Vector2) -> void:
	position = pos

func hit() -> void:
	emit_signal("enemy_died", self)
	
	_count -= 1
	#print_debug(_count)

func apply_force(value: Vector2) -> void:
	_linear_acceleration += (value * _force)

func _on_target_range_body_entered(body: Player) -> void:
	# only Player
	_target = body


func _on_target_range_body_exited(body: Player) -> void:
	# only Player
	_target = null


func _on_follow_range_body_entered(body: Enemy)-> void:
	pass
	#print(body)


func _on_follow_range_body_exited(body: Enemy)-> void:
	pass
	#print("exit", body)

extends Node2D

signal bullet_added
signal player_died

@export var type: Globals.Models

var _force: int = 256
var _torque: float = 2.5

var _linear_velocity: Vector2 = Vector2.ZERO
var _linear_acceleration: Vector2 = Vector2.ZERO

var _angular_velocity: float = 0
var _angular_acceleration: float = 0
var _hp: int = 32

# separate node?
var _is_shoot: bool = false

@onready var size = $Sprite2D.texture.get_size()

func _ready() -> void:
	prints(name, "ready")
	
	$Timer.connect("timeout", func(): _is_shoot = false)
	var screen_size: Vector2 = get_viewport().size
	add_to_group("Player")

	position = screen_size / 2
	
	#if _hp > 0:
		#$Area2D/CollisionShape2D.shape.radius = _hp
		#scale -= Vector2(1, 1) / (Vector2(_hp + 1, _hp + 1))
	#$AnimationPlayer.play("idle")
	
	$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE

func _process(delta: float) -> void:
	#_vector_key_movement(delta)
	_vector_mouse_movement(delta)

	_shoot()

func _vector_key_movement(delta: float) -> void:
	# dump
	_linear_velocity -= _linear_velocity * delta
	_angular_velocity -= _angular_velocity * delta

	if Input.is_action_pressed("ui_up"):
		_linear_acceleration += Vector2(_force, 0).rotated(rotation)
	if Input.is_action_pressed("ui_down"):
		_linear_acceleration -= Vector2(_force / 2, 0).rotated(rotation)
	if Input.is_action_pressed("ui_right"):
		_angular_acceleration += _torque
	if Input.is_action_pressed("ui_left"):
		_angular_acceleration -= _torque

	_linear_velocity += _linear_acceleration * delta
	_angular_velocity += _angular_acceleration * delta

#	reset
	_linear_acceleration = Vector2()
	_angular_acceleration = 0

	# move
	position += _linear_velocity * delta
	# rotate
	rotation += _angular_velocity * delta


func _vector_mouse_movement(delta: float) -> void:
	# dump
	_linear_velocity -= _linear_velocity * delta

	if Input.is_action_pressed("ui_up"):
		_linear_acceleration += Vector2(_force, 0).rotated(rotation)
	if Input.is_action_pressed("ui_down"):
		_linear_acceleration -= Vector2(_force / 2, 0).rotated(rotation)
	#if Input.is_action_pressed("ui_right"):
		#_linear_acceleration += Vector2( _force, 0)
	#if Input.is_action_pressed("ui_left"):
		#_linear_acceleration -= Vector2( _force, 0)

	_linear_velocity += _linear_acceleration * delta

#	reset
	_linear_acceleration = Vector2()

	# move
	position += _linear_velocity * delta

	# rotate
	var dir = get_global_mouse_position() - global_position

	if dir.length() > 5:
		rotation = dir.angle()

func _shoot():
	if Input.is_action_pressed("ui_left_mouse"):
		if !_is_shoot:
			_is_shoot = true
			var bullet = Globals.BULLET_SCENE.instantiate()
			bullet.start($Marker2D.global_position, _linear_velocity, rotation)

			emit_signal("bullet_added", bullet)

			$Timer.start(Globals.BULLET_DELAY)
	

func _on_area_2d_area_entered(_area: Area2D) -> void:
	_hp -= 1
	if _hp == 1:
		emit_signal("player_died")
	else:
		pass
		#$Area2D/CollisionShape2D.shape.radius = _hp
		#scale -= Vector2(1, 1) / (Vector2(_hp + 1, _hp + 1))

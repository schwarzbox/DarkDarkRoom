extends AnimatableBody2D

class_name Player

signal bullet_added
signal player_died
signal score_changed

@export var type: Globals.Models = Globals.Models.PLAYER

var _force: int = 256
var _torque: float = 2.5

var _linear_velocity: Vector2 = Vector2.ZERO
var _linear_acceleration: Vector2 = Vector2.ZERO

var _angular_velocity: float = 0
var _angular_acceleration: float = 0
var _hp: int = 32
var _min_hp: int = 8
var _max_hp: int = 32

var _score: int = 0: set = set_score

# separate node?
var _is_shoot: bool = false

var _tween: Tween

@onready var size = $Sprite2D.texture.get_size()

func _ready() -> void:
	prints(name, "ready")
	sync_to_physics = false

	$Timer.connect("timeout", func(): _is_shoot = false)

	#$AnimationPlayer.play("idle")
	
	#$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE

func _process(delta: float) -> void:
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
	#if Input.is_action_pressed("ui_right"):
		#_angular_acceleration += _torque
	#if Input.is_action_pressed("ui_left"):
		#_angular_acceleration -= _torque

	_linear_velocity += _linear_acceleration * delta

#	reset
	_linear_acceleration = Vector2()

	# move
	var collision = move_and_collide(_linear_velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if is_instance_of(collider, Enemy):
			hit()
			collider.hit()
			
	# rotate
	var dir = get_global_mouse_position() - global_position

	if dir.length() > 5:
		rotation = dir.angle()

	_shoot()

func start(pos: Vector2) -> void:
	position = pos
	_score = _score
	set_shape()
	
func hit() -> void:
	_hp -= 1
	if _hp <= _min_hp:
		emit_signal("player_died")
	else:
		set_shape()

func set_shape() -> void:
	if _tween:
		_tween.kill()
		
	_tween = create_tween()
	var diff: float = float(_hp) / float(_max_hp)
	_tween.tween_property(self, "scale", Vector2(diff, diff), 0.4)

func set_score(value: int) -> void:
	_score = value
	emit_signal("score_changed", _score)

func _shoot():
	if Input.is_action_pressed("ui_left_mouse"):
		if !_is_shoot:
			_is_shoot = true
			var bullet = Globals.BULLET_SCENE.instantiate()
			bullet.start($Marker2D.global_position, _linear_velocity, rotation)
			bullet.connect("bullet_removed", _on_bullet_removed)

			emit_signal("bullet_added", bullet)

			$Timer.start(Globals.BULLET_DELAY)

func _on_bullet_removed() -> void:
	_score += 1


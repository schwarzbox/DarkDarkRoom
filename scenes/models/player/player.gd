extends AnimatableBody2D

class_name Player

signal bullet_added
signal player_died
signal player_won
signal score_changed

@export var type: Globals.Models = Globals.Models.PLAYER

var sprite_size: Vector2

var _force: int = 256
var _torque: float = 2.5

var _linear_velocity: Vector2 = Vector2.ZERO
var _linear_acceleration: Vector2 = Vector2.ZERO

var _angular_velocity: float = 0
var _angular_acceleration: float = 0
var _hp: int = 32
var _min_hp: int = 8
var _max_hp: int = 32
var _died: bool = false
var _score: int = 0: set = set_score

# separate node?
var _is_shoot: bool = false

var _shape_tween: Tween


func _ready() -> void:
	prints(name, "ready")
	sync_to_physics = false

	$ShootTimer.wait_time = Globals.BULLET_DELAY
	$ShootTimer.connect("timeout", func(): _is_shoot = false)

	$RegenerationTimer.wait_time = Globals.REGENERATION_DELAY
	$RegenerationTimer.connect("timeout", _regenerate)
	$RegenerationTimer.start()

	sprite_size = $Sprite2D.texture.get_size()
	$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE
	#$AnimationPlayer.play("idle")


func _process(delta: float) -> void:
	if _died:
		return
	# dump
	_linear_velocity -= _linear_velocity * delta

	#if Input.is_action_pressed("ui_up"):
		#_linear_acceleration += Vector2(1, 0).rotated(rotation)
	#elif Input.is_action_pressed("ui_down"):
		#_linear_acceleration += Vector2(-1, 0).rotated(rotation)
#
	#if Input.is_action_pressed("ui_right"):
		#_linear_acceleration += Vector2(0, 1).rotated(rotation)
	#elif Input.is_action_pressed("ui_left"):
		#_linear_acceleration += Vector2(0, -1).rotated(rotation)

	_linear_acceleration.x += Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	_linear_acceleration.y += Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")


	_linear_velocity += _linear_acceleration.normalized() * _force * delta

	# reset
	_linear_acceleration = Vector2()

	# move
	var collision = move_and_collide(_linear_velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if is_instance_of(collider, Enemy):
			if !collider._died:
				hit()
			collider.hit()
		if is_instance_of(collider, Wall):
			_linear_velocity = _linear_velocity.bounce(collision.get_normal()) / 2

	# rotate
	var angle = global_position.angle_to_point(get_global_mouse_position())
	rotation = lerp_angle(rotation, angle, 0.1)

	_shoot()

func start(pos: Vector2) -> void:
	position = pos
	_score = _score
	_update_shape()

func hit() -> void:
	_hp -= 1
	if _hp <= _min_hp:
		if !_died:
			_died = true
			hide()
			emit_signal("player_died")
	else:
		_update_shape()

func set_score(value: int) -> void:
	_score = value
	emit_signal("score_changed", _score)

func win() -> void:
	emit_signal("player_won")

func _shoot():
	if Input.is_action_pressed("ui_left_mouse"):
		if !_is_shoot:
			hit()

			_is_shoot = true
			var bullet = Globals.BULLET_SCENE.instantiate()
			bullet.start($Marker2D.global_position, _linear_velocity, rotation)
			bullet.connect("bullet_removed", _on_bullet_removed)

			emit_signal("bullet_added", bullet)

			$AudioStreamPlayer2D.play()
			$ShootTimer.start()


func _regenerate() -> void:
	if _hp < _max_hp:
		_hp += 1
		_update_shape()

	$RegenerationTimer.start()

func _update_shape() -> void:
	if _shape_tween:
		_shape_tween.kill()

	_shape_tween = create_tween()
	var diff: float = float(_hp) / float(_max_hp)
	_shape_tween.tween_property(
		self, "scale", Vector2(diff, diff), Globals.PLAYER_SCALE_DOWN_DELAY
	)


func _on_bullet_removed() -> void:
	_score += 1


extends Node2D

@export var type: Globals.Models

var _speed: int = 64
var _score: int = 0

func _ready() -> void:
	prints(name, "ready")

	var screen_size: Vector2 = get_viewport().size

	position = screen_size / 2

	$AnimationPlayer.play("idle")

func _simple_movement(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		position.y -= delta * _speed
	if Input.is_action_pressed("ui_down"):
		position.y += delta * _speed
	if Input.is_action_pressed("ui_right"):
		position.x += delta * _speed
	if Input.is_action_pressed("ui_left"):
		position.x -= delta * _speed

func _tween_movement() -> void:
	var move = Vector2.ZERO
	move.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	move.y = Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")

	if move != Vector2.ZERO:
		(
			create_tween()
				.tween_property(self, "position", position + move * _speed, 0.5)
				.set_trans(Tween.TRANS_CUBIC)
				.set_ease(Tween.EASE_OUT)
		)

func _process(delta: float) -> void:
#	_simple_movement(delta)

	_tween_movement()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	print(_score)
	_score += 1

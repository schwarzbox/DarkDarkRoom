extends Node2D

signal player_died

@export var type: Globals.Models

var _speed: int = 64
@onready var size = $Sprite2D.texture.get_size()

@onready var _hp: int = 32

func _ready() -> void:
	prints(name, "ready")

	var screen_size: Vector2 = get_viewport().size
	add_to_group("Player")
	position = screen_size / 2

	if _hp > 0:
		$Area2D/CollisionShape2D.shape.radius = _hp
		scale -= Vector2(1, 1) / (Vector2(_hp + 1, _hp + 1))
	#$AnimationPlayer.play("idle")

func _tween_movement() -> void:
	var move = Vector2(Input.get_action_strength("ui_up"), 0)
	move = move.rotated(rotation)
	if move != Vector2.ZERO:
		(
			create_tween()
				.tween_property(self, "position", position + move * _speed, 0.5)
				.set_trans(Tween.TRANS_CUBIC)
				.set_ease(Tween.EASE_OUT)
		)

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	_tween_movement()
	

func _on_area_2d_area_entered(_area: Area2D) -> void:
	_hp -= 1
	if _hp == 1:
		emit_signal("player_died")
	else:
		$Area2D/CollisionShape2D.shape.radius = _hp
		scale -= Vector2(1, 1) / (Vector2(_hp + 1, _hp + 1))

extends Node

signal number_enemies_changed

@export var _enemy_scene: PackedScene

var _number_enemies: int = 0 : set = set_number_enemies

func _ready() -> void:
	prints(name, "ready")

func get_number_enemies() -> int:
	return _number_enemies

func set_number_enemies(value: int) -> void:
	_number_enemies = value
	emit_signal("number_enemies_changed", _number_enemies)

func generate_enemies(value: int):
	for _i in range(value):
		_number_enemies += 1
		var enemy: Node2D = _enemy_scene.instantiate()
		add_child(enemy)
		enemy.connect("enemy_died", _on_enemy_died)

func _on_enemy_died(child: Node2D) -> void:
	_number_enemies -= 1
	call_deferred("remove_child", child)
	

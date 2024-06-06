extends Node

signal number_enemies_changed

@export var _enemy_scene: PackedScene
@export var _number_enemies: int = 0 : set = set_number_enemies

func _ready() -> void:
	_number_enemies = _number_enemies
	generate_enemies()

func set_number_enemies(value: int) -> void:
	_number_enemies = value
	emit_signal("number_enemies_changed", _number_enemies)

func generate_enemies():
	_number_enemies = _number_enemies
	for _i in range(_number_enemies):
		var enemy: Node2D = _enemy_scene.instantiate()
		add_child(enemy)
		enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))

func _on_enemy_died(child: Node2D) -> void:
	call_deferred("remove_child", child)
	# use self because of setter
	_number_enemies -= 1

func _on_labirinth_level_changed(level: int):
	_number_enemies = 15 + level

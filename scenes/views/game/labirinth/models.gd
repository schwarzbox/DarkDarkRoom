extends Node

signal number_enemies_changed

@export var _enemy_scene: PackedScene

@export var steer_force: float = 20.0
@export var alignment_force: float = 30.0
@export var cohesion_force: float = 30.0
@export var separation_force: float = 50.0

var _number_enemies: int = 0 : set = set_number_enemies


func _ready() -> void:
	prints(name, "ready")

func _process(delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var cohesion_vector = Vector2.ZERO
	var alignment_vector = Vector2.ZERO
	
	
	for enemy in enemies:
		cohesion_vector += enemy.global_position
		alignment_vector += enemy._linear_velocity
	
	cohesion_vector /= enemies.size()
	alignment_vector /= enemies.size()
	for enemy in enemies:
		var separation_vector = Vector2.ZERO
		
		for id in enemy._closest:
			var closest = enemy._closest[id]
			var difference = enemy.global_position - closest.global_position
			separation_vector += difference.normalized() / difference.length()
		
		if enemy._closest.size():
			separation_vector /= enemy._closest.size()

		enemy._linear_acceleration += enemy.steer(cohesion_vector - enemy.global_position, steer_force) * cohesion_force  
		enemy._linear_acceleration += enemy.steer(alignment_vector, steer_force) * alignment_force
		enemy._linear_acceleration += enemy.steer(separation_vector, steer_force) * separation_force

func get_number_enemies() -> int:
	return _number_enemies

func set_number_enemies(value: int) -> void:
	_number_enemies = value
	emit_signal("number_enemies_changed", _number_enemies)

func generate_enemies(value: int):
	var screen_size: Vector2 = get_viewport().size
	
	for _i in range(value):
		_number_enemies += 1
		var enemy: Node2D = _enemy_scene.instantiate()
		add_child(enemy)
		var enemy_size = enemy.get_node("Sprite2D").texture.get_size()
		enemy.start(
			Vector2(randf_range(screen_size.x / 2 - enemy_size.x, screen_size.x / 2 + enemy_size.x), 32)
		)
	
		enemy.connect("enemy_died", _on_enemy_died)
		if _number_enemies % 10 == 0:
			$Timer.start()
			await $Timer.timeout

func _on_enemy_died(child: Node2D) -> void:
	_number_enemies -= 1
	call_deferred("remove_child", child)
	

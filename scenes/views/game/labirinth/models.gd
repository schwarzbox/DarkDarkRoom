extends Node

signal number_enemies_changed

@export var steer_force: float = 20.0
@export var alignment_force: float = 30.0
@export var cohesion_force: float = 30.0
@export var separation_force: float = 50.0


var _number_enemies: int = 0 : set = set_number_enemies

func _ready() -> void:
	prints(name, "ready")
	
	$EnemyTimer.wait_time = 0.2
	

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
	
	# create new enemies	
	if _number_enemies < 10:
		create_enemy()

func get_number_enemies() -> int:
	return _number_enemies

func set_number_enemies(value: int) -> void:
	_number_enemies = value
	emit_signal("number_enemies_changed", _number_enemies)

func create_enter(pos: Vector2) -> void:
	var enter: Enter = Globals.ENTER_SCENE.instantiate()
	add_child(enter)
	enter.start(pos)

func create_exit(pos: Vector2) -> void:
	var exit: Exit = Globals.EXIT_SCENE.instantiate()
	add_child(exit)
	exit.start(pos)
	
func create_enemy() -> void:
	var exit_position: Vector2 = get_node("Exit").position
	_number_enemies += 1
	var enemy: Enemy = Globals.ENEMY_SCENE.instantiate()
	add_child(enemy)
	# find better way to set position
	enemy.start(
		Vector2(
				randf_range(
					exit_position.x - enemy.sprite_size.x, exit_position.x + enemy.sprite_size.x
				),
				randf_range(
					exit_position.y - enemy.sprite_size.y, exit_position.y + enemy.sprite_size.y
				)
			)
		)
	enemy.connect("enemy_died", _on_enemy_died)
		
	if _number_enemies % 10 == 0:
		$EnemyTimer.start()
		await $EnemyTimer.timeout

func _on_enemy_died(child: Node2D) -> void:
	_number_enemies -= 1
	call_deferred("remove_child", child)
	

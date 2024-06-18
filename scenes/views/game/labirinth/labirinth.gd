extends View

#var _alarm: Alarm

var _level: int = 0
var _enemies_per_level: int = 50

var _lab_wid: int = 12
var _lab_hei: int = 12
var _lab_tile_size: Vector2 = Vector2(128, 128)
var _map: Array[Array]

func _ready() -> void:
	prints(name, "ready")

	$AudioStreamPlayer.play()

	for node in $CanvasLayer/VBoxContainer.get_children():
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.EXTRA_FONT_SIZE
		)
	$CanvasLayer/GameOver.hide()
	$CanvasLayer/GameOver/Label.modulate.a = 0.0

	# alarm
	#_alarm = (
		#Alarm
		#. new(
			#Globals.ALARM_WAIT_TIME,
			#Globals.FONTS.SMALL_FONT_SIZE,
			#Globals.COLORS.ORANGE,
		#)
	#)
	#_alarm.connect("timeout", _on_alarm_timeout)
	#$CanvasLayzer.add_child(_alarm)
	#_alarm.start(Globals.ALARM_WAIT_TIME)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				emit_signal("view_exited", self)
			#if event.keycode == KEY_R:
				#emit_signal("view_restarted", self)
			if event.keycode == KEY_P:

				get_tree().paused = not get_tree().paused
				if get_tree().paused:
					$AudioStreamPlayer.stop()
					#_alarm.pause()
				else:
					$AudioStreamPlayer.play()
					#_alarm.resume()

func add_models_child(child: Node) -> void:
	$World/Models.add_child(child)

func remove_models_child(child: Node) -> void:
	$World/Models.remove_child(child)


func start(level: int, player: Player):
	_level = level
	$CanvasLayer/VBoxContainer/LevelLabel.text = "Level " + str(_level)

	# Generate labirinth
	_map = _create_map(_lab_wid, _lab_hei, Globals.Models.WALL)
	_generate_labirinth(1, 1)

	var screen_size: Vector2 = get_viewport().size
	var enter_position: Vector2
	var exit_position: Vector2

	for y: int in range(0, _lab_hei):
		for x: int in range(0, _lab_wid):
			if _map[x][y] == Globals.Models.WALL:
				var pos: Vector2 = Vector2(x, y) * _lab_tile_size + _lab_tile_size * 0.5
				$World/Models.create_wall(pos)
			if !enter_position:
				if _map[x][y] == Globals.Models.EMPTY:
					enter_position = Vector2(x, y) * _lab_tile_size + _lab_tile_size * 0.5
			if y > _lab_hei / 2:
				if !exit_position:
					if _map[x][y] == Globals.Models.EMPTY:
						exit_position = Vector2(x, y) * _lab_tile_size +  _lab_tile_size * 0.5

	$World/Models.create_enter(enter_position)
	$World/Models.create_exit(exit_position)
	for i in range(_level * _enemies_per_level):
		$World/Models.create_enemy()

	# Setup player
	player.connect("bullet_added", add_models_child)
	player.connect("player_died", _on_player_died)
	player.connect("player_won", _on_player_won)
	player.connect("score_changed", _on_player_score_changed)
	add_models_child(player)

	player.start(enter_position)

func _create_map(wid: int, hei: int, model_type: Globals.Models) -> Array[Array]:
	var map: Array[Array] = []
	for i in range(wid):
		var col = []
		col.resize(hei)
		col.fill(model_type)
		map.append(col)

	return map

func _find_closest(x: int, y: int, model_type: Globals.Models) -> int:
	var closest: int  = 0
	for dy: int in range(-1, 2):
		for dx: int in range(-1, 2):
			if dx == 0 && dy == 0:
				continue

			var xx = x - dx
			var yy = y - dy
			if xx >= 0 && xx < _lab_wid && yy >= 0 && yy < _lab_hei:
				if _map[xx][yy] == model_type:
					closest += 1
	return closest

func _cut_caves() -> void:
	var caves_positions: Array = []
	for y: int in range(0, _lab_hei):
		for x: int in range(0, _lab_wid):
			if _map[x][y] == Globals.Models.WALL:
				var closest = _find_closest(
					x, y, Globals.Models.EMPTY
				)
				if closest >= 5:
					caves_positions.append(Vector2(x, y))

	for value: Vector2 in caves_positions:
		_map[value.x][value.y] = Globals.Models.EMPTY

func _cut_dead_ends() -> void:
	var dead_ends_positions: Array = []
	for y: int in range(0, _lab_hei):
		for x: int in range(0, _lab_wid):
			if _map[x][y] == Globals.Models.EMPTY:
				var closest = _find_closest(
					x, y, Globals.Models.EMPTY
				);
				if closest <= 1:
					dead_ends_positions.append(Vector2(x, y))

	for value: Vector2 in dead_ends_positions:
		_map[value.x][value.y] = Globals.Models.WALL

func _generate_labirinth(caves: int = 3, deadends: int = 2) -> void:
	var ix = randi_range(1, _lab_wid - 2)
	var iy = randi_range(1, _lab_hei - 2)

	_map[ix][iy] = Globals.Models.EMPTY

	var to_check: Array = []
	if iy - 2 > 0:
		to_check.append(Vector2(ix, iy - 2))
	if iy + 2 < _lab_hei - 1:
		to_check.append(Vector2(ix, iy + 2))
	if ix - 2 > 0:
		to_check.append(Vector2(ix - 2, iy))
	if ix + 2 < _lab_wid - 1:
		to_check.append(Vector2(ix + 2, iy))

	while to_check.size() > 0:
		var cell: Vector2 = to_check.pick_random()

		ix = cell.x;
		iy = cell.y;

		_map[ix][iy] = Globals.Models.EMPTY

		to_check = to_check.filter(func(value): return value != cell)

		# Clear the cell between them
		var directions: Array = [0, 1, 2, 3]
		while directions.size() > 0:
			var random_direction = directions.pick_random()
			match random_direction:
				0:
					if iy - 2 >= 0 && _map[ix][iy - 2] == Globals.Models.EMPTY:
						_map[ix][iy - 1] = Globals.Models.EMPTY
						directions = []
				1:
					if iy + 2 < _lab_hei &&  _map[ix][iy + 2] == Globals.Models.EMPTY:
						_map[ix][iy + 1] = Globals.Models.EMPTY
						directions = []
				2:
					if ix - 2 >= 0 && _map[ix - 2][iy] == Globals.Models.EMPTY:
						_map[ix - 1][iy] = Globals.Models.EMPTY
						directions = []
				3:
					if ix + 2 < _lab_wid && _map[ix + 2][iy] == Globals.Models.EMPTY:
						_map[ix + 1][iy] = Globals.Models.EMPTY
						directions = []

			directions = directions.filter(
				func(direction): return direction != random_direction
			)

			if iy - 2 > 0 && _map[ix][iy - 2] == Globals.Models.WALL:
				to_check.append(Vector2(ix, iy - 2))
			if iy + 2 < _lab_hei - 1 && _map[ix][iy + 2] == Globals.Models.WALL:
				to_check.append(Vector2(ix, iy + 2))
			if ix - 2 > 0 && _map[ix - 2][iy] == Globals.Models.WALL:
				to_check.append(Vector2(ix - 2, iy))
			if ix + 2 < _lab_wid - 1 && _map[ix + 2][iy] == Globals.Models.WALL:
				to_check.append(Vector2(ix + 2, iy))

	for i: int in range(0, deadends):
		_cut_dead_ends()
	for i: int in range(0, caves):
		_cut_caves()
	#for i: int in range(0, deadends):
		#_cut_dead_ends()

#func _on_alarm_timeout():
	#print_debug("Alarm!")


func _on_models_number_enemies_changed(value: int) -> void:
	#if not is_inside_tree():
		#await self.ready

	$CanvasLayer/VBoxContainer/EnemyLabel.text = "Cells " + str(value)

	#if value == 0:
		#emit_signal("view_changed", self)

func _on_player_score_changed(value: int) -> void:
	$CanvasLayer/VBoxContainer/ScoreLabel.text = "Score " + str(value)

func _on_player_won() -> void:
	emit_signal("view_changed", self)

func _on_player_died() -> void:
	$CanvasLayer/VBoxContainer.hide()
	$CanvasLayer/GameOver.show()
	var tween = create_tween()
	tween.tween_property($CanvasLayer/GameOver/Label, "modulate:a", 1.0, 2.0)
	tween.tween_property($CanvasLayer/GameOver/Label, "modulate:a", 0.0, 2.0)
	tween.parallel().tween_property($AudioStreamPlayer, "volume_db", -10, 2.0)
	tween.tween_callback(
		func(): emit_signal("view_exited", self)
	)


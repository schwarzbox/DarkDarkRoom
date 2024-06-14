extends View

var _alarm: Alarm

var _level: int = 0
var _enemies_per_level: int = 50

func _ready() -> void:
	prints(name, "ready")

	for node in $CanvasLayer/VBoxContainer.get_children():
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)

	# alarm
	_alarm = (
		Alarm
		. new(
			Globals.ALARM_WAIT_TIME,
			Globals.FONTS.DEFAULT_FONT_SIZE,
			Globals.COLORS.ORANGE,
		)
	)
	_alarm.connect("timeout", _on_alarm_timeout)
	$CanvasLayer.add_child(_alarm)
	_alarm.start(Globals.ALARM_WAIT_TIME)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				emit_signal("view_exited", self)
			if event.keycode == KEY_R:
				emit_signal("view_restarted", self)
			if event.keycode == KEY_P:
				get_tree().paused = not get_tree().paused
				if get_tree().paused:
					_alarm.pause()
				else:
					_alarm.resume()

	
func start(level: int, player: Player):
	_level = level
	$CanvasLayer/VBoxContainer/LevelLabel.text = "Level " + str(_level)
	# Setup player
	add_child(player)
	player.connect("bullet_added", add_models_child)
	player.connect("player_died", _on_player_died)
	player.connect("player_won", _on_player_won)
	player.connect("score_changed", _on_player_score_changed)
	
	# Generate labirinth
	# create_walls()
	var screen_size: Vector2 = get_viewport().size
	var enter_position = Vector2(screen_size.x / 2, screen_size.y)
	$World/Models.create_enter(enter_position)
	$World/Models.create_exit(Vector2(screen_size.x / 2, 0))
	for i in range(_level * _enemies_per_level):
		$World/Models.create_enemy()
	
	player.start(enter_position)
	
func add_models_child(child: Node) -> void:
	$World/Models.add_child(child)

func remove_models_child(child: Node) -> void:
	$World/Models.remove_child(child)

func _on_alarm_timeout():
	print_debug("Alarm!")


func _on_models_number_enemies_changed(value: int) -> void:
	#if not is_inside_tree():
		#await self.ready

	$CanvasLayer/VBoxContainer/EnemyLabel.text = "Enemies " + str(value)

	if value == 0:
		emit_signal("view_changed", self)

func _on_player_score_changed(value: int) -> void:
	$CanvasLayer/VBoxContainer/ScoreLabel.text = "Score " + str(value)

func _on_player_won() -> void:
	emit_signal("view_changed", self)

func _on_player_died() -> void:
	emit_signal("view_exited", self)

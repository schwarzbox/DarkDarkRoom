extends View

signal level_changed

func _ready() -> void:
	prints(name, "ready")

	$CanvasLayer/Label.add_theme_font_size_override(
		"font_size", Globals.FONTS.GAME_FONT_SIZE
	)
	
	# alarm
	var alarm = (
		Alarm
		. new(
			Globals.ALARM_WAIT_TIME,
			Globals.FONTS.DEFAULT_FONT_SIZE,
			Globals.COLORS.ORANGE,
		)
	)
	alarm.connect("timeout", _on_alarm_timeout)
	$CanvasLayer.add_child(alarm)
	alarm.start(Globals.ALARM_WAIT_TIME)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				emit_signal("view_exited", self)
			#if event.keycode == KEY_R:
				#emit_signal("view_restarted", self)
			#if event.keycode == KEY_P:
				#get_tree().paused = not get_tree().paused

func add_models_child(child: Node) -> void:
	$World/Models.add_child(child)

func remove_models_child(child: Node) -> void:
	$World/Models.remove_child(child)
	
func next_level(level: int):
	emit_signal("level_changed", level)
	$World/Models.generate_enemies()

func _on_alarm_timeout():
	print_debug("Alarm!")

func _on_models_number_enemies_changed(value: int) -> void:
	if not is_inside_tree():
		await self.ready

	$CanvasLayer/Label.text = "Enemies " + str(value)

	if value == 0:
		emit_signal("view_changed", self)

func _on_player_died() -> void:
	emit_signal("view_exited", self)

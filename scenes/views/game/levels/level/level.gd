extends View

func _ready() -> void:
	prints(name, "ready")

	$CanvasLayer/Label.add_theme_font_size_override(
		"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				emit_signal("view_exited", self)
			if event.keycode == KEY_R:
				emit_signal("view_restarted", self)
			if event.keycode == KEY_P:
				get_tree().paused = not get_tree().paused

func add_models_child(child: Node) -> void:
	$World/Models.add_child(child)

func remove_models_child(child: Node) -> void:
	$World/Models.remove_child(child)

func _on_models_number_enemies_changed(value: int) -> void:
	if not is_inside_tree():
		await self.ready

	$CanvasLayer/Label.text = "Enemies " + str(value)

	if value == 0:
		emit_signal("view_changed", self)

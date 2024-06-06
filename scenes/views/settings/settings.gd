extends View

func _ready() -> void:
	prints(name, "ready")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			emit_signal("view_exited", self)

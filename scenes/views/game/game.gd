extends View

const PLAYER_SCENE: PackedScene = preload("res://scenes/models/player/player.tscn")
var player: Node2D = null

var _views: Array = []
var _views_scenes: Dictionary = {
	" - 1 - ": preload("res://scenes/views/game/levels/level/level.tscn")
}

func _ready() -> void:
	prints(name, "ready")

	for node in [
		$CanvasLayer/Menu/VBoxContainer/Label,
		$CanvasLayer/Menu/VBoxContainer/Back
	]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)

	var keys = _views_scenes.keys()
	for i in range(keys.size()):
		var button: Button = Button.new()
		button.text = keys[i]
		button.connect("pressed", Callable(self, "_on_view_started").bind(i))
		button.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)

		$CanvasLayer/Menu/VBoxContainer/GridContainer.add_child(button)

	_setup()

func _setup() -> void:
	player = PLAYER_SCENE.instantiate()
	_views.clear()

	for view_scene in _views_scenes.values():
		var node: Node = view_scene.instantiate()
		node.connect("view_restarted", self._on_view_restarted)
		node.connect("view_changed", self._on_view_changed)
		node.connect("view_exited", self._on_view_exited)
		_views.append(node)

	$CanvasLayer.show()
	$AudioStreamPlayer.play()

func _start(view: Node) -> void:
	view.add_models_child(player)
	add_world_child(view)

	if is_world_has_children():
		$CanvasLayer.hide()
		$AudioStreamPlayer.stop()

func _change(view: Node) -> void:
	# save view state
	view.remove_models_child(player)
	remove_world_child(view)

	var index: int = _views.find(view)
	if index < _views.size()-1:
		call_deferred("_start", _views[index+1])
	else:
		view.queue_free()
		call_deferred("_setup")

func _on_view_started(index: int) -> void:
	call_deferred("_start", _views[index])

func _on_view_restarted(view: Node) -> void:
	view.queue_free()
	var index: int = _views.find(view)
	_setup()
	call_deferred("_start", _views[index])

func _on_view_changed(view: Node) -> void:
	_set_transition(_change, view)

func _on_view_exited(view: Node) -> void:
	view.queue_free()
	_set_transition(_setup)

func _on_back_pressed() -> void:
	emit_signal("view_exited", self)

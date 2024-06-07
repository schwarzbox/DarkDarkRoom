extends View

# Remove all Debug calls
# Problem with menu texture I want big adaptive screen 
# reset labirinth 

var _views: Array = []
var _views_scenes: Array[PackedScene] = [Globals.GAME_SCENE, Globals.SETTINGS_SCENE]

func _ready() -> void:
	prints(name, "ready")
	
	_center_window_on_screen()

	for node in [
		$CanvasLayer/Menu/VBoxContainer/Game,
	]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)

	randomize()

	# warning-ignore:return_value_discarded
	connect("tree_exiting", self._on_main_exited)

	_setup()
	
func _center_window_on_screen() -> void:
	var window: Window = get_window()
	var window_id: int = window.get_window_id()
	var display_id: int  = DisplayServer.window_get_current_screen(window_id)

	var window_size: Vector2i = window.get_size_with_decorations()
	var display_size: Vector2i = DisplayServer.screen_get_size(display_id)
	var window_position: Vector2i = (display_size / 2) - (window_size /2)
	window.position = window_position


func _notification(what: int) -> void:
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		prints("_notification", what)


func _setup() -> void:
	_views.clear()

	for view in _views_scenes:
		var node: Node = view.instantiate()
		# warning-ignore:return_value_discarded
		node.connect("view_exited", self._on_view_exited)
		_views.append(node)

	$CanvasLayer.show()

func _start(view: Node) -> void:
	add_world_child(view)

	if is_world_has_children():
		$CanvasLayer.hide()

func _on_game_pressed() -> void:
	await _set_transition(_start, _views[0])

func _on_settings_pressed() -> void:
	await _set_transition(_start, _views[1])

func _on_view_exited(view: Node) -> void:
	view.queue_free()
	await _set_transition(_setup)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_main_exited() -> void:
	prints(name, "exited")

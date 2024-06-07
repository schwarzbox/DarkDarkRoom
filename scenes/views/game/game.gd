extends View

var player: Node2D = null

var LABIRINTH_SCENE: PackedScene = preload("res://scenes/views/game/labirinth/labirinth.tscn")
var labirinth: View = null
var level: int = 0

func _ready() -> void:
	prints(name, "ready")

	for node in [
		$CanvasLayer/Menu/VBoxContainer/Label,
		$CanvasLayer/Menu/VBoxContainer/Button,
		$CanvasLayer/Menu/VBoxContainer/Back
	]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)

	_setup()

func _setup() -> void:
	player = Globals.PLAYER_SCENE.instantiate()
	labirinth = LABIRINTH_SCENE.instantiate()
	
	player.connect("bullet_added", labirinth.add_models_child)
	player.connect("player_died", Callable(labirinth, "_on_player_died"))

	labirinth.connect("view_restarted", self._on_view_restarted)
	labirinth.connect("view_changed", self._on_view_changed)
	labirinth.connect("view_exited", self._on_view_exited)
		
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

	level += 1
	labirinth.next_level(level)
	call_deferred("_start", labirinth)

func _on_view_started() -> void:
	call_deferred("_start", labirinth)

func _on_view_restarted(view: Node) -> void:
	view.queue_free()
	_setup()
	call_deferred("_start", labirinth)

func _on_view_changed(view: Node) -> void:
	await _set_transition(_change, view)

func _on_view_exited(view: Node) -> void:
	view.queue_free()
	await _set_transition(_setup)

func _on_back_pressed() -> void:
	emit_signal("view_exited", self)

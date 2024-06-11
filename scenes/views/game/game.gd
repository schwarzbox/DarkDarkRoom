extends View

var player: Node2D = null

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
	level = 0
	labirinth = Globals.LABIRINTH_SCENE.instantiate()
	player = Globals.PLAYER_SCENE.instantiate()
		
	$CanvasLayer.show()
	#$AudioStreamPlayer.play()

func _start(view: Node) -> void:
	# Setup view
	level += 1
	view.add_models_child(player)
	
	view.connect("view_restarted", self._on_view_restarted)
	view.connect("view_changed", self._on_view_changed)
	view.connect("view_exited", self._on_view_exited)
	add_world_child(view)
	# Set level because we need this number to generate correct labirinth
	view.start(level) 
	
	# Setup player
	player.connect("bullet_added", view.add_models_child)
	player.connect("player_died", view._on_player_died)
	player.connect("score_changed", view._on_player_score_changed)
	var screen_size: Vector2 = get_viewport().size
	player.start(screen_size / 2)
	
	if is_world_has_children():
		$CanvasLayer.hide()
		$AudioStreamPlayer.stop()

func _change(view: Node) -> void:
	remove_world_child(view)
	view.remove_models_child(player)
	view.queue_free()
	# initialize new labirinth
	labirinth = Globals.LABIRINTH_SCENE.instantiate()

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

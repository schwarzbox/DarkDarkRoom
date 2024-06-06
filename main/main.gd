#tool
#class_name
#extends
extends View
#docstring
# Main Scene

# Remove all Debug calls
# Set display/window/vsync/vsync_mode to Enabled
# Set application/run/max_fps to 60

# Custom font
# gui/theme/custom_font

# Editor preset
# interface/theme/preset

# Stretch mode
# display/window/stretch/mode

# Hints
# Autoload scenes as Global
# Use AtlasTextures for TextureButtons

#inner classes
#signals
#enums
#constants
#exported variables
#public variables
#private variables
var _views: Array = []
var _views_scenes = [
	preload("res://scenes/views/game/game.tscn"),
	preload("res://scenes/views/settings/settings.tscn")
]
#public onready variables
#private onready variables

#optional built-in virtual _init method
#built-in virtual _ready method
func _ready() -> void:
	prints(name, "ready")

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
#remaining built-in virtual methods
#public methods
#private methods
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

#private signal receiver methods
func _on_game_pressed() -> void:
	_set_transition(_start, _views[0])

func _on_settings_pressed() -> void:
	_set_transition(_start, _views[1])

func _on_view_exited(view: Node) -> void:
	view.queue_free()
	_set_transition(_setup)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_main_exited() -> void:
	prints(name, "exited")
#public static methods
#private static methods

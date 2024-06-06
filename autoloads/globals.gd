extends Node

func _ready() -> void:
	prints(name, "ready")

const FONTS: Dictionary = {
	GAME_FONT_SIZE = 16,
	DEFAULT_FONT_SIZE = 24,
}

enum Models {
	PLAYER,
}

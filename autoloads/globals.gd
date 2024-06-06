extends Node

func _ready() -> void:
	prints(name, "ready")

const FONTS: Dictionary = {
	DEFAULT_FONT_SIZE = 24,
}

enum Models {
	PLAYER,
}

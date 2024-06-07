extends CanvasLayer

signal finished

var _reference: Callable
var _level: Node = null


func _ready() -> void:
	prints(name, "ready")


func fade(reference: Callable, level: Node = null) -> void:
	_reference = reference
	_level = level

	$AnimationPlayer.play("Fade")
	await finished


func _exe() -> void:
	if _reference:
		if _level:
			_reference.call(_level)
		else:
			_reference.call()

	emit_signal("finished")


extends CenterContainer

class_name Alarm

signal timeout

enum TimeFormat { SECONDS, MINUTES }

var _time_formats: Dictionary = {
	TimeFormat.SECONDS: "{seconds}",
	TimeFormat.MINUTES: "{minutes} : {seconds}",
}

var _wait_time: int
var _highlight_color: Color
var _default_color: Color = Color("#FFFFFF")
var _anchors_preset: LayoutPreset
var _time_format: TimeFormat

var _tween: Tween


func _init(
	wait_time: int,
	font_size: int,
	highlight_color: Color = Color("#FFFFFF"),
	anchor: LayoutPreset = PRESET_CENTER_TOP,
	time_format: TimeFormat = TimeFormat.SECONDS,
) -> void:
	name = "Alarm"
	_wait_time = wait_time
	_highlight_color = highlight_color
	_anchors_preset = anchor
	_time_format = time_format

	var label: Label = Label.new()
	label.text = _get_time_string()
	label.name = "Label"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)

	var timer: Timer = Timer.new()
	timer.name = "Timer"
	timer.wait_time = _wait_time
	timer.connect("timeout", _on_timer_timeout)
	add_child(timer)


func _ready() -> void:
	# Start timer explicitly
	anchors_preset = _anchors_preset


func get_time_left() -> int:
	return $Timer.get_time_left()


func start(wait_time: int) -> void:
	# Run with wait_time for the initial round
	$Timer.start(wait_time)
	# Reset time for the second round
	$Timer.wait_time = _wait_time
	_on_timer_countdown()
	if _tween:
		_tween.kill()
	_tween = create_tween().set_loops()
	_tween.tween_callback(_on_timer_countdown).set_delay(1)


func pause() -> void:
	$Timer.set_paused(true)


func resume() -> void:
	if $Timer.is_paused():
		$Timer.set_paused(false)
	else:
		start(_wait_time)


func _get_time_string(minutes: int = 0, seconds: int = 0):
	return _time_formats[_time_format].format(
		{minutes = "%0*d" % [2, minutes], seconds = "%0*d" % [2, seconds]}
	)


func _on_timer_countdown() -> void:
	var time_left: int = $Timer.time_left
	var minutes: int = time_left / 60
	var seconds: int = time_left % 60
	if minutes == 0 && seconds <= 10:
		if seconds % 2 == 0:
			$Label.modulate = _highlight_color
		else:
			$Label.modulate = _default_color
	$Label.text = _get_time_string(minutes, seconds)


func _on_timer_timeout() -> void:
	$Label.modulate = _default_color
	emit_signal("timeout")

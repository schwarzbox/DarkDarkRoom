extends AnimatableBody2D

class_name Bullet

signal bullet_removed

@export var type: Globals.Models = Globals.Models.BULLET

var _force: int = 1024
var _linear_velocity: Vector2 = Vector2.ZERO
var _died: bool = false
var _in_combo: bool = false
var _died_tween: Tween
var _closest: Dictionary = {}

func _ready() -> void:
	#prints(name, "ready")
	sync_to_physics = false

	$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE

func _process(delta: float) -> void:
	# dump
	_linear_velocity -= _linear_velocity * delta

	# move
	if !_died:
		var collision = move_and_collide(_linear_velocity * delta)
		# collide
		if collision:
			var collider = collision.get_collider()
			if is_instance_of(collider, Enemy):
				if !collider._died:
					hit()
				collider.hit()
			if is_instance_of(collider, Wall):
				hit(false)
			if is_instance_of(collider, Bullet):
				collider.hit()
				hit(false)
			

	# combo
	if _in_combo:
		var collision = move_and_collide(_linear_velocity * delta)
		if collision:
			var collider = collision.get_collider()
			if is_instance_of(collider, Enemy):
				collider.hit()
			if is_instance_of(collider, Wall):
				hit(false)
			if is_instance_of(collider, Bullet):
				collider.hit()
				hit(false)
	else:
		_combo()

	# destroy
	if !_died && _linear_velocity.length_squared() < Globals.BULLET_MIN_FORCE:
		queue_free()

func start(pos: Vector2, other_vel: Vector2, dir: float) -> void:
	position = pos + Vector2(randi_range(-4, 4), randi_range(-4, 4))
	rotation = dir
	_linear_velocity = (other_vel + Vector2(_force, 0)).rotated(rotation)

func hit(with_delay: bool = true) -> void:
	if !_died:
		_died = true
		_linear_velocity = Vector2.ZERO
		var _tween = create_tween()
		if with_delay:
			_tween.tween_interval(Globals.BULLET_COMBO_DELAY)
			
		_tween.tween_property(self, "scale", Vector2(0, 0), Globals.BULLET_SCALE_DOWN_DELAY)
		_tween.tween_callback(
			func():
				emit_signal("bullet_removed")
				queue_free()
		)
	

func _combo() -> void:
	match _closest.size():
		0: pass
		1: _magnet()
		_: _magnet()
		#2: print(2)
		#3: print(3)

func _magnet() -> void:
	var closest = _closest.values()
	var dot1 = self
	var dot2 = closest[0]
	
	if is_instance_valid(dot1) && is_instance_valid(dot2):
		if (dot1.global_position - dot2.global_position).length() < 64:
			return

		dot1._in_combo = true

		_closest.erase(dot2.get_instance_id())
		dot2._in_combo = true

		var angle: float = dot1.global_position.angle_to_point(dot2.get_global_position())
		print(dot1.rotation)
		dot1.rotation = angle
		print(dot1.rotation)
		print(dot1._linear_velocity)
		dot1._linear_velocity = Vector2(dot1._force, 0).rotated(dot1.rotation)
		print(dot1._linear_velocity)
		#var angle2: float = dot1.global_position.angle_to_point(dot2.get_global_position())
		dot2.rotation = -angle
		print(dot2.rotation)
		dot2._linear_velocity = Vector2(dot2._force, 0).rotated(dot2.rotation)
		print(dot2._linear_velocity)

func _on_combo_range_body_entered(body: Bullet) -> void:
	if body != self && body._died && !_in_combo:
		_closest[body.get_instance_id()] = body


func _on_combo_range_body_exited(body: Bullet) -> void:
	if body != self:
		_closest.erase(body.get_instance_id())


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()




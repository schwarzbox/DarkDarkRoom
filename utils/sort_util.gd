class_name SortUtil

extends Resource

static func _sort_by_position(a: Node2D, b: Node2D):
	if a.position > b.position:
		return true
	return false

class_name SortUtil

extends Resource

static func _sort_by_position(a: Element, b: Element):
    if a.position > b.position:
        return true
    return false

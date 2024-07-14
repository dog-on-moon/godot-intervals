@tool
extends Event
class_name RouterBase
## Base class for routers.

var chosen_branch := 0

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(func (): chosen_branch = 0),
		Func.new(done.emit)
	])

func get_branch_count() -> int:
	return 1

func get_branch_names() -> Array:
	var base_list := super()
	for i in get_branch_count():
		base_list.append("Choice #%s" % (i + 1))
	return base_list

func get_branch_index() -> int:
	return chosen_branch

static func get_graph_args() -> Dictionary:
	return super().merged({
		"title": "Router: Base",
		"category": "Control",
		"modulate": Color.CORNFLOWER_BLUE,
		
		"flatten_initial_connection_label": false,
		"make_node_controls": false,
		"can_create": false,
	})

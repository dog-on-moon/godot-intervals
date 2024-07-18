@tool
extends RouterBase
class_name RouterState
## A routing event that picks branches based on state.

@export var key := &""

@export var value := 0

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(func (): 
			if key in _state:
				var check_val: int = _state[key]
				if check_val == value:
					chosen_branch = 2
				elif check_val < value:
					chosen_branch = 1
				else:
					chosen_branch = 3
			else:
				chosen_branch = 4
			),
		# backport 4.2: Wrap Signal.emit in lambda
		Func.new(func(): done.emit())
	])

static func get_graph_node_title() -> String:
	return "Router: State Value"

static func is_in_graph_dropdown() -> bool:
	return true

func get_branch_names() -> Array:
	var branches: Array[String] = [
		"Default",
		"'%s' > %s" % [key, value],
		"'%s' = %s" % [key, value],
		"'%s' < %s" % [key, value],
		"'%s' unset" % [key],
	]
	return branches

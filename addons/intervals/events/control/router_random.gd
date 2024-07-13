@tool
extends RouterBase
class_name RouterRandom
## A routing event that chooses a random branch.

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	chosen_branch = 1 + randi_range(0, branches - 1)
	return super(_owner, _state)

static func get_graph_node_title() -> String:
	return "Router: Random"

static func is_in_graph_dropdown() -> bool:
	return true

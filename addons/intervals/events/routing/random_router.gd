@tool
extends Event
class_name RandomRouter
## A routing event that chooses a random branch.

@export var branches := 2

var chosen_branch := 0

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	chosen_branch = 1 + randi_range(0, branches - 1)
	return super(_owner, _state)

## Gets the names of the outgoing branches.
## Note that MultiEvents are responsible for linking branches.
func get_branch_names() -> Array:
	var base_list := super()
	for i in branches:
		base_list.append("Branch #%s" % (i + 1))
	return base_list

## Determines the branch index we're choosing based on internal state.
func get_branch_index() -> int:
	return chosen_branch

## The color that represents this event in the editor.
static func get_editor_color() -> Color:
	return Color.CORNFLOWER_BLUE

## String representation of the event. Important to define.
static func get_editor_name() -> String:
	return "Router: Random"

## The editor category that the event belongs to.
static func get_editor_category() -> String:
	return "Routing"

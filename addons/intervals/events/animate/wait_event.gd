@tool
extends Event
class_name WaitEvent
## Waits a short period of time.

@export var duration := 2.0

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	if not is_zero_approx(duration):
		return Sequence.new([
			Wait.new(duration),
			Func.new(done.emit)
		])
	else:
		return super(_owner, _state)

#region Base Editor Overrides
static func get_graph_args() -> Dictionary:
	return super().merged({
		"title": "Wait",
		"category": "Animate",
	})

func get_graph_node_description(_edit: GraphEdit2, _element: GraphElement) -> String:
	return "[b]Duration:[/b] %s seconds" % duration
#endregion

@tool
extends Event
class_name PrintEvent
## Prints out a message into the output.

@export_multiline var msg := ""
@export var enabled := true

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(print_rich.bind(msg)),
		Func.new(done.emit)
	]) if enabled else Func.new(done.emit)

static func get_graph_args() -> Dictionary:
	return super().merged({
		"title": "Print to Console",
		"category": "Meta",
	})

func get_graph_node_description(_edit: GraphEdit2, _element: GraphElement) -> String:
	return ("[color=ff6666][s]" if not enabled else "") + (msg if msg else "[color=red][b][No Message]")

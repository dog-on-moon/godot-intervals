@tool
extends Event
class_name CommentEvent
## Displays a comment in the event editor, but otherwise has no logic.

@export_multiline var msg := ""

static func get_graph_args() -> Dictionary:
	return super().merged({
		"title": "Comment",
		"category": "Meta",
	})

func get_graph_node_description(_edit: GraphEdit2, _element: GraphElement) -> String:
	return msg

func get_input_connections() -> int:
	return 0

func get_output_connections() -> int:
	return 0

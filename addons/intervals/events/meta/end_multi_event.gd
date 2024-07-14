@tool
extends Event
class_name EndMultiEvent
## A special event that instantly terminates a MultiEvent.

func get_branch_names() -> Array[String]:
	return []

static func get_graph_args() -> Dictionary:
	return super().merged({
		"title": "MultiEvent End",
		"category": "Meta",
		"modulate": MultiEvent._args['modulate'],
		
		## Determines if we should flatten the default connection label.
		"flatten_initial_connection_label": true,
		"icon": preload("res://addons/intervals/icons/event.png"),
	})

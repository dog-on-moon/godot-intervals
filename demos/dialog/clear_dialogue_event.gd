@tool
extends Event
class_name ClearDialogueEvent

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(DialogueContainer.singleton.clear_text),
		Func.new(done.emit)
	])

static func get_graph_args() -> Dictionary:
	return super().merged({
		"title": "End Dialogue",
		"category": "Demo/Dialogue",
		"modulate": DialogueEvent._args['modulate'],
		"node_min_width": 0,
	})

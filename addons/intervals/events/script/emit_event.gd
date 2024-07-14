@tool
extends SignalEvent
class_name EmitEvent
## An event that emits a signal immediately.

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var node: Node = _owner.get_node(node_path)
	return Sequence.new([
		Func.new(node.emit_signal.bind(signal_name)),
		Func.new(done.emit)
	])

static func get_graph_args() -> Dictionary:
	return super().merged({
		"title": "Signal",
		"category": "Script",
		"modulate": FuncEvent._args['modulate'],
	})

func _get_editor_description_prefix() -> String:
	return "Emitting"

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


static func get_editor_color() -> Color:
	return FuncEvent.get_editor_color()

static func get_editor_name() -> String:
	return "Emit Signal"

func _get_editor_description_prefix() -> String:
	return "Emitting"

static func get_editor_category() -> String:
	return "General"

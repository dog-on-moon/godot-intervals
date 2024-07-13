@tool
extends Event
class_name ClearDialogueEvent

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(DialogueContainer.singleton.clear_text),
		Func.new(done.emit)
	])

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Demo/Dialogue"

static func get_graph_node_title() -> String:
	return "End Dialogue"

static func get_graph_node_color() -> Color:
	return DialogueEvent.get_graph_node_color()
#endregion

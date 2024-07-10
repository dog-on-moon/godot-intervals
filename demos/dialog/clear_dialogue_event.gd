@tool
extends Event
class_name ClearDialogueEvent

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(DialogueContainer.singleton.clear_text),
		Func.new(done.emit)
	])

static func get_editor_color() -> Color:
	return DialogueEvent.get_editor_color()

static func get_editor_name() -> String:
	return "Clear Dialogue"

static func get_editor_category() -> String:
	return "Demo/Dialogue"

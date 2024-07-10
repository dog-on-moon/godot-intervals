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

static func get_editor_color() -> Color:
	return FuncEvent.get_editor_color()

static func get_editor_name() -> String:
	return "Wait"

func get_editor_description_text(_owner: Node) -> String:
	return "[b]Duration:[/b] %s" % duration

static func get_editor_category() -> String:
	return "General"

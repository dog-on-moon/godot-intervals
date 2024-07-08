extends Event
class_name WaitEvent

@export var duration := 5.0

func _get_interval(owner: Node, state: Dictionary) -> Interval:
	if not is_zero_approx(duration):
		return Sequence.new([
			Wait.new(duration),
			Func.new(done.emit)
		])
	else:
		return super(owner, state)


#region Editor Overrides
## The color that represents this event in the editor.
static func get_editor_color() -> Color:
	return FuncEvent.get_editor_color()

## String representation of the event. Important to define.
static func get_editor_name() -> String:
	return "WaitEvent"

## The editor description of the event.
func get_editor_description_text(owner: Node) -> String:
	return "[b]Duration:[/b] %s" % duration

## The editor category that the event belongs to.
static func get_editor_category() -> String:
	return "General"
#endregion

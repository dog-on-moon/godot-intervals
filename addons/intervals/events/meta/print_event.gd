@tool
extends Event
class_name PrintEvent

@export_multiline var msg := ""

func _get_interval(owner: Node, state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(print_rich.bind(msg)),
		Func.new(done.emit)
	])

## String representation of the event. Important to define.
static func get_editor_name() -> String:
	return "PrintEvent"

## The editor description of the event.
func get_editor_description_text(owner: Node) -> String:
	return msg

## The editor category that the event belongs to.
static func get_editor_category() -> String:
	return "Meta"

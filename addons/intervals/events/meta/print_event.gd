@tool
extends Event
class_name PrintEvent
## Prints out a message into the output.

@export_multiline var msg := ""
@export var enabled := true

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Sequence.new([
		Func.new(print_rich.bind(msg)),
		Func.new(done.emit)
	]) if enabled else Func.new(done.emit)

## String representation of the event. Important to define.
static func get_editor_name() -> String:
	return "Print"

## The editor description of the event.
func get_editor_description_text(_owner: Node) -> String:
	return ("[color=ff6666][s]" if not enabled else "") + msg

## The editor category that the event belongs to.
static func get_editor_category() -> String:
	return "Meta"

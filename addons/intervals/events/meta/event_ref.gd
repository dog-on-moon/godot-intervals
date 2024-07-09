@tool
extends Event
class_name EventRef

## The event to perform by reference.
@export var event: Event

func _get_interval(owner: Node, state: Dictionary) -> Interval:
	event.done.connect(done.emit, CONNECT_ONE_SHOT)
	return event._get_interval(owner, state)

#region Editor Overrides
static func get_editor_name() -> String:
	return "EventRef"

static func get_editor_category() -> String:
	return "Meta"

func get_editor_description_text(owner: Node) -> String:
	return ("[b]Referencing:[/b] %s" % event.to_string()) if event else ("[color=red]No Reference")
#endregion

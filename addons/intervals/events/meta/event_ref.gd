@tool
extends Event
class_name EventRef
## Performs an event by reference.

@export var event: Event

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	event.done.connect(done.emit, CONNECT_ONE_SHOT)
	return event._get_interval(_owner, _state)

static func get_editor_name() -> String:
	return "Event Ref"

static func get_editor_category() -> String:
	return "Meta"

func get_editor_description_text(_owner: Node) -> String:
	return ("[b]Referencing:[/b] %s" % event.to_string()) if event else ("[color=red]No Reference")

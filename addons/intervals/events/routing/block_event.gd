@tool
extends Event
class_name BlockEvent
## Given an event by reference,
## blocks until that event's done is emitted.

## An external event (by reference). Should be present elsewhere in the cutscene.
## Does not emit done until or unless that event has emitted done.
@export var event: Event

var is_done := false
var is_reached := false

func _init() -> void:
	if not Engine.is_editor_hint():
		setup.call_deferred()

func setup():
	event.done.connect(on_done)

## Returns the interval for this specific event.
## Must be implemented by event subclasses.
func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Func.new(on_reached)

func reset():
	is_done = false
	is_reached = false

func on_done():
	is_done = true
	if is_reached:
		reset()
		done.emit()

func on_reached():
	is_reached = true
	if is_done:
		reset()
		done.emit() 

#region Editor Overrides
## The color that represents this event in the editor.
static func get_editor_color() -> Color:
	return SignalEvent.get_editor_color()

## String representation of the event. Important to define.
static func get_editor_name() -> String:
	return "Await Event"

## The editor description of the event.
func get_editor_description_text(_owner: Node) -> String:
	return ("[b]Waiting On:[/b] %s" % event.to_string()) if event else "[color=red]Event Undefined"

## The editor category that the event belongs to.
static func get_editor_category() -> String:
	return "Routing"

## Set up the editor info container.
## This is the Control widget that appears within the Event nodes (above the connections).
func _editor_ready(_owner: Node, _info_container: EventEditorInfoContainer):
	_info_container.add_new_button("View Block", 1).pressed.connect(func ():
		if event:
			_info_container.event_node.inspect_event.emit(event)
	)
#endregion

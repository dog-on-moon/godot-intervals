@tool
@icon("res://addons/intervals/icons/event.png")
extends Resource
class_name Event
## An Interval resource with playback logic for dynamic cutscenes.
##
## Events can be used to describe and build clusters of timed actions together.
## These actions can be blocking, and can be used to build complex, dynamic cutscenes.
## Events emit [signal done] on completion.
## A [MultiEvent] can play back multiple linear or branching events.
##
## Subclasses must implement [method _get_interval].

const EventEditorInfoContainer = preload("res://addons/intervals/editor/event_editor_info_container.gd")

## Emitted when this event is complete.
signal done()

## Returns the interval for this specific event.
## Must be implemented by event subclasses.
## Remember to emit [signal done].
func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	return Func.new(done.emit)

#region Editor Overrides
## The color that represents this event in the editor.
static func get_editor_color() -> Color:
	return Color.DIM_GRAY

## String representation of the event.
## This is used for the editor node headers
## and name in the creation dropdown.
static func get_editor_name() -> String:
	return "Event"

## The editor description of the event.
## This will render text within a RichTextLabel within the editor node.
func get_editor_description_text(_owner: Node) -> String:
	return ""

## The editor category that the event belongs to.
## This defines the folder path for new event types when creating one.
## You can also define nested categories with /s.
static func get_editor_category() -> String:
	return ""

## Set up EventNode in the editor.
## The InfoContainer is the Control widget that appears within the Event nodes (above the connections).
## Here you can add new buttons to the info dropdown or do all kinds of zany things.
func _editor_setup(_owner: Node, _info_container: EventEditorInfoContainer):
	pass

## Process function for the EventNode in the editor.
## Called on the editor's process thread when the node is rendering.
## Return true to force a size fix on the event node.
func _editor_process(_owner: Node, _info_container: EventEditorInfoContainer) -> bool:
	return false
#endregion

#region Routing Internal
## Performs the event. When it is finished, [signal done] will be emitted.
func play(_owner: Node, callback: Callable = _do_nothing, _state: Dictionary = {}) -> Tween:
	if callback != _do_nothing:
		done.connect(callback, CONNECT_ONE_SHOT)
	return _get_interval(_owner, _state).as_tween(_owner)

## Gets the names of the outgoing branches.
## Note that MultiEvents are responsible for linking branches.
func get_branch_names() -> Array:
	return ["Default"]

## Determines the branch index we're choosing based on internal state.
func get_branch_index() -> int:
	return 0

## Returns true if this event has connection ports.
func has_connection_ports() -> bool:
	return true

## Returns true if this event should be visible in the creation menu.
static func _editor_can_be_created() -> bool:
	return true
#endregion

#region Dev
func _to_string() -> String:
	return resource_name if resource_name else get_editor_name()

static func get_node_path_string(_owner: Node, np: NodePath) -> String:
	var valid_np := np and _owner and _owner.get_node_or_null(np)
	return _owner.get_node(np).name if valid_np else "[color=red]Invalid NodePath[/color]"

## Prints debugging information on this event.
func print_debug_info():
	print("--- EVENT '%s' ACTIVE ---" % self)
	print("resource_name: %s" % resource_name)
	for property in get_property_list():
		if not property['usage'] & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		print('%s: %s' % [property['name'], self[property['name']]])
	print("-------------------------")

# Does nothing. :(
static func _do_nothing():
	pass
#endregion

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
func _get_interval(owner: Node, state: Dictionary) -> Interval:
	return Func.new(done.emit)

#region Editor Overrides
## The color that represents this event in the editor.
static func get_editor_color() -> Color:
	return Color.DIM_GRAY

## String representation of the event. Important to define.
static func get_editor_name() -> String:
	return "Event"

## The editor description of the event.
func get_editor_description_text(owner: Node) -> String:
	return ""

## The editor category that the event belongs to.
static func get_editor_category() -> String:
	return ""

## Set up the editor info container.
## This is the Control widget that appears within the Event nodes (above the connections).
func setup_editor_info_container(owner: Node, info_container: EventEditorInfoContainer):
	pass
#endregion

#region Routing Internal
## Performs the event. When it is finished, [signal done] will be emitted.
func play(owner: Node, callback: Callable = _do_nothing, state: Dictionary = {}) -> Tween:
	if callback != _do_nothing:
		done.connect(callback, CONNECT_ONE_SHOT)
	return _get_interval(owner, state).as_tween(owner)

## Gets the names of the outgoing branches.
## Note that MultiEvents are responsible for linking branches.
func get_branch_names() -> Array:
	return ["Default"]

## Determines the branch index we're choosing based on internal state.
func get_branch_index() -> int:
	return 0
#endregion

#region Dev
func _to_string() -> String:
	return resource_name if resource_name else get_editor_name()

static func get_node_path_string(owner: Node, np: NodePath) -> String:
	var valid_np := np and owner and owner.get_node_or_null(np)
	return ('[b]%s[/b] "^%s"' % [owner.get_node(np).name, np]) if valid_np else "[color=red]Invalid NodePath[/color]"

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

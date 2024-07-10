@tool
extends Event
class_name EndMultiEvent
## A special event that instantly terminates a MultiEvent.

#region Editor Overrides
## The color that represents this event in the editor.
static func get_editor_color() -> Color:
	return MultiEvent.get_editor_color()

## String representation of the event. Important to define.
static func get_editor_name() -> String:
	return "Terminate"

static func get_editor_category() -> String:
	return "Routing"
#endregion

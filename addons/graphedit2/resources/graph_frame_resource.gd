@icon("res://addons/graphedit2/icons/ResGraphFrame.png")
@tool
extends GraphElementResource
class_name GraphFrameResource
## A resource for information within a GraphFrame.

## Returns the title of the GraphFrame.
static func get_graph_frame_title() -> String:
	return "Frame"

## Returns the color of the GraphFrame.
static func get_graph_frame_color() -> Color:
	return Color.WHITE

static func get_graph_dropdown_icon_modulate(script: Script = null) -> Color:
	return script.get_graph_frame_color() if script else get_graph_frame_color()

func _make_graph_control() -> Control:
	return GraphFrame2.new()

func _to_string() -> String:
	return resource_name if resource_name else get_graph_frame_title()

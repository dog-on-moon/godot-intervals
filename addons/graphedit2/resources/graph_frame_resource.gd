@icon("res://addons/graphedit2/icons/ResGraphFrame.png")
@tool
extends GraphElementResource
class_name GraphFrameResource
## A resource for information within a GraphFrame.

## Returns the title of the GraphFrame.
static func get_graph_frame_title() -> String:
	return "GraphFrame"

## Returns the color of the GraphFrame.
static func get_graph_frame_color() -> Color:
	return Color.WHITE

func _make_graph_control() -> Control:
	return GraphFrame2.new()

func _to_string() -> String:
	return resource_name if resource_name else get_graph_frame_title()

## Returns True if a given resource has correctly implemented our trait.
static func validate_implementation(resource: Resource) -> bool:
	return resource is GraphNodeResource or (resource \
		and GraphElementResource.validate_implementation(resource) \
		and resource.has_method(&"get_graph_frame_title") \
		and resource.has_method(&"get_graph_frame_color"))

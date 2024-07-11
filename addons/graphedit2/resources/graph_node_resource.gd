@icon("res://addons/graphedit2/icons/ResGraphNode.png")
@tool
extends GraphElementResource
class_name GraphNodeResource
## A resource for information within a GraphNode.

## Returns the title of the GraphNode.
static func get_graph_node_title() -> String:
	return "GraphNode"

## Returns the color of the GraphNode.
static func get_graph_node_color() -> Color:
	return Color.WHITE

## Returns the number of inbound connections.
func get_inbound_connections() -> int:
	return 0

## Returns the number of outbound connections.
func get_outbound_connections() -> int:
	return 0

func _make_graph_control() -> Control:
	return GraphNode2.new()

func _to_string() -> String:
	return resource_name if resource_name else get_graph_node_title()

## Returns True if a given resource has correctly implemented our trait.
static func validate_implementation(resource: Resource) -> bool:
	return resource is GraphNodeResource or (resource \
		and GraphElementResource.validate_implementation(resource) \
		and resource.has_method(&"get_graph_node_title") \
		and resource.has_method(&"get_graph_node_color") \
		and resource.has_method(&"get_inbound_connections") \
		and resource.has_method(&"get_outbound_connections"))

@icon("res://addons/graphedit2/icons/ResGraphElement.png")
@tool
extends Resource
class_name GraphElementResource
## A resource for information within a Element.

## Called once when the GraphElement is created.
func _editor_ready(edit: GraphEdit, element: GraphElement):
	pass

## Called each frame that the GraphElement is active.
func _editor_process(edit: GraphEdit, element: GraphElement) -> bool:
	return false

## The editor category that the element belongs to.
## This defines the folder path for the Graph Dropdown.
## You can also define nested categories with '/'s.
static func get_graph_dropdown_category() -> String:
	return ""

## Returns true if this Element should be visible in the creation menu.
static func is_in_graph_dropdown() -> bool:
	return true

## Returns a new Control node to possess this resource.
func _make_graph_control() -> Control:
	return GraphElement2.new()

## Returns True if a given resource has correctly implemented our trait.
static func validate_implementation(resource: Resource) -> bool:
	return resource is GraphElementResource or (resource \
		and resource.has_method(&"_editor_ready") \
		and resource.has_method(&"_editor_process") \
		and resource.has_method(&"get_graph_dropdown_category") \
		and resource.has_method(&"is_in_graph_dropdown")) \
		and resource.has_method(&"_make_graph_control")

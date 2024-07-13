@icon("res://addons/graphedit2/icons/ResGraphElement.png")
@tool
extends Resource
class_name GraphElementResource
## A resource for information within a Element.

## Called once when the Resource is added to a GraphEditResource.
func _enter():
	pass

## Called once when the GraphElement is created.
func _editor_ready(edit: GraphEdit, element: GraphElement):
	pass

## Called each frame that the GraphElement is active.
func _editor_process(edit: GraphEdit, element: GraphElement):
	pass

## The editor category that the element belongs to.
## This defines the folder path for the Graph Dropdown.
## You can also define nested categories with '/'s.
static func get_graph_dropdown_category() -> String:
	return ""

## The icon that the element uses in the dropdown.
static func get_graph_dropdown_icon() -> Texture2D:
	return null

## The modulate applied to the dropdown icon.
static func get_graph_dropdown_icon_modulate(script: Script = null) -> Color:
	return Color.WHITE

## The max width of the icon used in the dropdown.
static func get_graph_dropdown_icon_max_width() -> int:
	return 16

## Returns true if this Element should be visible in the creation menu.
static func is_in_graph_dropdown() -> bool:
	return true

## Returns true if this Element can be copied.
static func graph_can_be_copied() -> bool:
	return true

## Returns a new Control node to possess this resource.
func _make_graph_control() -> Control:
	return GraphElement2.new()

@icon("res://addons/graphedit2/icons/ResGraphElement.png")
@tool
extends Resource
class_name GraphElementResource
## A resource for information within a Element.

## Static arguments for representing this class.
static var _args := get_graph_args()

## Called once when the Resource is added to a GraphEditResource.
func _enter():
	pass

## Called once when the GraphElement is created.
func _editor_ready(edit: GraphEdit2, element: GraphElement):
	pass

## Called each frame that the GraphElement is active.
func _editor_process(edit: GraphEdit2, element: GraphElement):
	pass

## Returns the information that GraphEdit2 needs to display this element.
static func get_graph_args() -> Dictionary:
	return {
		## The name of the element.
		"title": "",
		
		## The editor category that the element belongs to.
		## This defines the folder path for the Graph Dropdown.
		## You can also define nested categories with '/'s.
		"category": "",
		
		## The color associated with this element.
		"modulate": Color.WHITE,
		
		## The icon that the element uses in the dropdown.
		"icon": null,
		"icon_max_width": 16,
		
		## Returns true if this Element should be visible in the creation popup menu.
		"can_create": true,
		
		## Returns true if this Element can be copied.
		"can_copy": true,
	}

## Returns a new Control node to possess this resource.
func _make_graph_control() -> Control:
	return GraphElement2.new()

func _to_string() -> String:
	return resource_name if resource_name else _args['title']

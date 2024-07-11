@tool
extends PopupMenu
class_name GraphEdit2PopupMenu
## A GraphEdit2 component that appears upon right-clicking the frame.
## Shows basic operations and keybinds for the editor.

signal request_create_resource(resource: Resource, position: Vector2)

var graph_edit: GraphEdit2:
	get: return get_parent()
var resource: Resource:
	get: return graph_edit.resource

var _activation_position := Vector2.ZERO
var _activation_mode := 0
var _activation_resource: Resource = null
var _activation_port: = 0

## Sets up the the Popup element.
## Can pass in state from a GraphNodeResource to request a connection
## after request_resource has been emitted.
func activate(pos: Vector2, resource: Resource = null, port_idx: int = 0, from_output_port := false):
	position = get_viewport().get_mouse_position()
	_activation_position = pos
	_activation_mode = 0 if not resource else (1 if from_output_port else 2)
	_activation_resource = resource
	_activation_port = port_idx
	_setup_popup_menu()
	show()

func deactivate():
	clear(true)
	hide()

## Called to set up the popup menu.
func _setup_popup_menu():
	_create_resource_menu(self)

## Creates popup menu elements for all resource classes defined by the graph edit.
func _create_resource_menu(parent: PopupMenu):
	var element_resource_classes: Array = graph_edit.get_element_resource_classes()
	if not element_resource_classes:
		return
	# todo

## Creates a resource by script.
func _create_resource(resource_class: Script):
	var resource: Resource = resource_class.new()
	request_create_resource.emit(resource, _activation_position)
	match _activation_mode:
		1:
			## Connect from existing output port
			self.resource.connect_resources(_activation_resource, _activation_port, resource, 0)
		2:
			## Connect from existing input port
			self.resource.connect_resources(resource, 0, _activation_resource, _activation_port)
	deactivate()

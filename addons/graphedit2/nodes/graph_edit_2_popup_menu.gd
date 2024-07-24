@tool
extends PopupMenu
class_name GraphEdit2PopupMenu
## A GraphEdit2 component that appears upon right-clicking the frame.
## Shows basic operations and keybinds for the editor.

const DELIMITER = "/"

signal request_create_resource(resource: Resource, position: Vector2)
signal request_paste_resources(position: Vector2)

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
	position = DisplayServer.mouse_get_position()
	_activation_position = pos
	_activation_mode = 0 if not resource else (1 if from_output_port else 2)
	_activation_resource = resource
	_activation_port = port_idx
	clear()
	for signal_data in get_signal_connection_list(&"id_pressed"):
		disconnect(&"id_pressed", signal_data['callable'])
	_setup_popup_menu()
	show()
	
	# reposition to make sure we are still onscreen
	var screen_position := DisplayServer.screen_get_position(current_screen)
	var screen_size := EditorInterface.get_base_control().size
	position.y = min(position.y, screen_position.y + screen_size.y - size.y)

func deactivate():
	hide()

## Called to set up the popup menu.
func _setup_popup_menu():
	_create_resource_menu(self)

## Creates popup menu elements for all resource classes defined by the graph edit.
func _create_resource_menu(parent: PopupMenu):
	## Get all visible element classes.
	var element_resource_classes: Array = graph_edit.get_element_resource_classes()
	element_resource_classes = element_resource_classes.filter(
		func (x): return x.is_in_graph_dropdown()
	)
	if not element_resource_classes:
		return
	
	## Create a dict for mapping all categories.
	var category_dict := {"": {}}  # defining default path for no category
	for resource_class in element_resource_classes:
		var category_path: String = resource_class.get_graph_dropdown_category()
		var categories := category_path.split(DELIMITER)
		var curr_dict := category_dict
		for category: String in categories:
			curr_dict = curr_dict.get_or_add(category, {})
	
	## Build the header items.
	var category_path_to_popup_menu := {"": parent}
	_recusrive_make_category_items(category_dict, category_path_to_popup_menu, parent)
	
	## Create all category for events groups.
	var groups := {}
	for resource_class in element_resource_classes:
		var category: String = resource_class.get_graph_dropdown_category()
		groups.get_or_add(category, []).append([
			resource_class.get_graph_node_title() if &"get_graph_node_title" in resource_class
			else (resource_class.get_graph_frame_title() if &"get_graph_frame_title" in resource_class
			else 'Undefined')
		, resource_class])
	for group_array: Array in groups.values():
		group_array.sort_custom(func (a, b): return a[0] < b[0])
	
	# Build all tree items now.
	for category in groups:
		for event_data: Array in groups[category]:
			## Get menu.
			var item_name: String = event_data[0]
			var resource_class: GDScript = event_data[1]
			
			var icon: Texture2D = resource_class.get_graph_dropdown_icon()
			var modulate: Color = resource_class.get_graph_dropdown_icon_modulate(resource_class)
			var width: int = resource_class.get_graph_dropdown_icon_max_width()
			
			## Create menu item.
			var parent_menu: PopupMenu = category_path_to_popup_menu.get(category)
			var id: int = parent_menu.item_count
			parent_menu.add_item(item_name, id)
			if icon:
				parent_menu.set_item_icon(id, icon)
				parent_menu.set_item_icon_modulate(id, modulate)
				if width:
					parent_menu.set_item_icon_max_width(id, width)
			
			parent_menu.id_pressed.connect(func(x):
				if x == id:
					_create_resource(resource_class)
			)
	
	# Add paste button if present.
	if graph_edit.element_clipboard:
		var id: int = parent.item_count
		parent.add_item("Paste", id)
		parent.id_pressed.connect(func (x):
			if x == id:
				var new_resources: Array = graph_edit.element_clipboard.keys()
				request_paste_resources.emit(_activation_position)
				for res in new_resources:
					match _activation_mode:
						2:
							## Connect from existing input port
							if self.resource.get_resource_inputs(res):
								continue
							self.resource.connect_resources(_activation_resource, _activation_port, res, 0)
						1:
							## Connect from existing output port
							if self.resource.get_resource_outputs(res):
								continue
							self.resource.connect_resources(res, 0, _activation_resource, _activation_port)
		)

## Creates a resource by script.
func _create_resource(resource_class: Script):
	var resource: Resource = resource_class.new()
	request_create_resource.emit(resource, _activation_position)
	match _activation_mode:
		2:
			## Connect from existing input port
			self.resource.connect_resources(_activation_resource, _activation_port, resource, 0)
		1:
			## Connect from existing output port
			self.resource.connect_resources(resource, 0, _activation_resource, _activation_port)
	deactivate()

func _recusrive_make_category_items(category_dict: Dictionary, out: Dictionary, parent: PopupMenu, path: String = ""):
	## Get all of the headers for this dictionary.
	var categories: Array = category_dict.keys()
	categories.sort()
	
	## Create a tree item for each header.
	for category: String in categories:
		var category_path := category if not path else path + DELIMITER + category
		var category_menu := parent
		if category_path:
			category_menu = PopupMenu.new()
			parent.add_submenu_node_item(category, category_menu)
			out[category_path] = category_menu
		
		_recusrive_make_category_items(category_dict[category], out, category_menu, category_path)

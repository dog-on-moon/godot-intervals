@tool
extends GraphEdit
class_name GraphEdit2

var undo_redo: EditorUndoRedoManager:
	get: return GraphEdit2Plugin.undo_redo

var _resource_ref: WeakRef

## Sets the resource for the GraphEdit.
## Resource must have all traits defined.
## (Until traits are implemented, GraphEditResource is a usable base class)
@export var resource: Resource:
	set(x):
		if not x or _validate_resource(x):
			if resource:
				resource.editor_refresh.disconnect(_refresh)
			_resource_ref = weakref(resource)
			selected_elements = []
			if resource:
				resource.editor_refresh.connect(_refresh)
			if is_node_ready():
				_refresh()
				recenter()
	get:
		return _resource_ref.get_ref()

## Validate that a resource has all of the traits for the GraphEdit.
func _validate_resource(resource: Resource) -> bool:
	if not resource:
		return false
	if resource is GraphEditResource:
		return true
	return GraphEditResource.validate_implementation(resource)

var resource_to_element := {}
var active_elements: Array[GraphElement] = []
var selected_elements: Array[GraphElement] = []

var element_clipboard := {}
var clipboard_pos := Vector2.ZERO

var popup_menu: GraphEdit2PopupMenu

func _ready() -> void:
	## GraphEdit signals
	connection_request.connect(_connection_request)
	connection_from_empty.connect(_connection_from_empty)
	connection_to_empty.connect(_connection_to_empty)
	disconnection_request.connect(_disconnection_request)
	copy_nodes_request.connect(_copy_nodes_request)
	paste_nodes_request.connect(_paste_nodes_request)
	delete_nodes_request.connect(_delete_nodes_request)
	duplicate_nodes_request.connect(_duplicate_nodes_request)
	end_node_move.connect(_end_node_move)
	node_selected.connect(_node_selected)
	node_deselected.connect(_node_deselected)
	popup_request.connect(_popup_request)
	
	## Create popup menu
	popup_menu = _get_popup_menu_class().new()
	add_child(popup_menu)
	popup_menu.hide()
	
	## Popup menu signals
	popup_menu.request_create_resource.connect(add_resource)

#region GraphEdit Signals
func _connection_request(from_node_name: StringName, from_port: int, to_node_name: StringName, to_port: int):
	assert(resource)
	var from_node: GraphNode2 = get_node(NodePath(from_node_name))
	var to_node: GraphNode2 = get_node(NodePath(to_node_name))
	undo_redo.create_action("Connect GraphNodes" % resource)
	undo_redo.add_do_method  (resource, &"connect_resources",    from_node.resource, from_port, to_node.resource, to_port)
	undo_redo.add_undo_method(resource, &"disconnect_resources", from_node.resource, from_port, to_node.resource, to_port)
	undo_redo.commit_action()

func _connection_from_empty(to_node: StringName, to_port: int, release_position: Vector2):
	assert(resource)
	var pos := (release_position + scroll_offset) / zoom
	var resource: Resource = get_node(NodePath(to_node)).resource
	popup_menu.activate(pos, resource, to_port, true)

func _connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2):
	assert(resource)
	var pos := (release_position + scroll_offset) / zoom
	var resource: Resource = get_node(NodePath(from_node)).resource
	popup_menu.activate(pos, resource, from_port, false)

func _disconnection_request(from_node_name: StringName, from_port: int, to_node_name: StringName, to_port: int):
	assert(resource)
	var from_node: GraphNode2 = get_node(NodePath(from_node_name))
	var to_node: GraphNode2 = get_node(NodePath(to_node_name))
	undo_redo.create_action("Disconnect GraphNodes" % resource)
	undo_redo.add_do_method  (resource, &"disconnect_resources", from_node.resource, from_port, to_node.resource, to_port)
	undo_redo.add_undo_method(resource, &"connect_resources",    from_node.resource, from_port, to_node.resource, to_port)
	undo_redo.commit_action()

func _copy_nodes_request():
	element_clipboard = {}
	clipboard_pos = scroll_offset
	for node in selected_elements:
		element_clipboard[node.resource.duplicate()] = node.position_offset - clipboard_pos

func _paste_nodes_request():
	assert(resource)
	for node in selected_elements.duplicate():
		node.set_selected(false)
	var old_clipboard := element_clipboard.duplicate()
	element_clipboard = {}
	for resource in old_clipboard:
		add_resource(resource, old_clipboard[resource] - clipboard_pos + (scroll_offset * 2))
		resource_to_element[resource].set_selected(true)
		element_clipboard[resource.duplicate()] = old_clipboard[resource]

func _delete_nodes_request(nodes: Array[StringName]):
	assert(resource)
	for node_name in nodes:
		var node: Node = get_node(NodePath(node_name))
		if node is GraphElement:
			remove_resource(node.resource)

func _duplicate_nodes_request():
	assert(resource)
	for node in selected_elements.duplicate():
		var res: Resource = node.resource
		var idx: int = resource.resources.find(res)
		var res_dupe := res.duplicate()
		add_resource(res_dupe, node.position_offset)
		node.set_selected(false)
		resource_to_element[res_dupe].set_selected(true)

func _end_node_move():
	assert(resource)
	for node in active_elements:
		var node_pos: Vector2 = resource.positions[node.resource]
		var target_pos := node.position_offset + scroll_offset
		resource.move_resource(node.resource, target_pos)
		# TODO - this undo is super broken and idk why
		#undo_redo.create_action("%s move event %s" % [multi_event.to_string(), get_tree().get_frame()], UndoRedo.MERGE_ALL)
		#undo_redo.add_do_method(multi_event, &"set_event_editor_position", node.event, target_pos)
		#undo_redo.add_undo_method(self, &"_move_node", node, node_pos, node.position_offset)
		#undo_redo.commit_action()

func _node_selected(node: Node):
	assert(resource)
	if node is GraphElement:
		selected_elements.append(node)

func _node_deselected(node: Node):
	assert(resource)
	if node is GraphElement:
		selected_elements.erase(node)

func _popup_request(at_position: Vector2):
	assert(resource)
	popup_menu.activate((at_position + scroll_offset) / zoom)
#endregion

#region Editor interface
## Adds a Resource into the GraphEdit.
func add_resource(resource: Resource, position: Vector2):
	assert(self.resource)
	undo_redo.create_action("New GraphElement(s) %s" % [self.resource.to_string(), get_tree().get_frame()], UndoRedo.MERGE_ALL)
	undo_redo.add_do_method(self.resource, &"add_resource", resource, position)
	undo_redo.add_undo_method(self.resource, &"remove_resource", resource)
	undo_redo.commit_action()

## Removes a Resource from the GraphEdit.
func remove_resource(resource: Resource):
	assert(self.resource)
	undo_redo.create_action("Delete GraphElement(s) %s" % [self.resource.to_string(), get_tree().get_frame()], UndoRedo.MERGE_ALL)
	undo_redo.add_do_method(self.resource, &"remove_resource", resource)
	undo_redo.add_undo_method(self.resource, &"add_resource", resource, self.resource.positions[resource])
	undo_redo.commit_action()

## Refreshes the state of the GraphEdit.
func _refresh():
	if not resource:
		## Cleanup.
		clear_connections()
		for element in active_elements.duplicate():
			element.queue_free()
		resource_to_element = {}
		active_elements = []
	else:
		## Delete un-accounted for nodes.
		var existing_resources := {}
		for element in active_elements.duplicate():
			if not is_instance_valid(element) or element.resource not in resource.resources:
				selected_elements.erase(element)
				active_elements.erase(element)
				element.queue_free()
			else:
				existing_resources[element.resource] = null
		
		## Create missing nodes.
		for res in resource.resources:
			if res not in existing_resources:
				var element: Control = res._make_graph_control()
				element.resource = res
				resource_to_element[res] = element
				active_elements.append(element)
				add_child(element)
				element.position_offset = resource.positions[res]
		
		## Rebuild connections.
		## Dictionary[Resource, Dict[int, Array[Resource]]]
		clear_connections()
		for c: GraphEditResource.Connection in resource.connections:
			var from_node: GraphNode2 = resource_to_element[c.from_resource]
			var to_node: GraphNode2 = resource_to_element[c.to_resource]
			connect_node(from_node.name, c.from_port, to_node.name, c.to_port)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cut") and selected_elements:
		element_clipboard = {}
		for node in selected_elements.duplicate():
			element_clipboard[node.resource] = node.position_offset - scroll_offset
			remove_resource(node.resource)
		clipboard_pos = scroll_offset
		accept_event()

## Recenters the GraphEdit.
func recenter():
	zoom = 1.0
	await get_tree().process_frame
	if not active_elements:
		scroll_offset = Vector2.ZERO
		return
	var average_node_position := Vector2.ZERO
	for node in active_elements:
		average_node_position += node.position_offset + (node.size / 2)
	average_node_position /= active_elements.size()
	scroll_offset = average_node_position - (size / 2)

#region Editor overrides
## Returns an array of all element resource classes that can be created in this GraphEdit.
static func get_element_resource_classes() -> Array:
	return [GraphElementResource, GraphFrameResource, GraphNodeResource]

## Gets the popup menu class used for 
static func _get_popup_menu_class() -> Script:
	return GraphEdit2PopupMenu
#endregion

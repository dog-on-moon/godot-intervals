@tool
extends GraphEdit

const EventNode = preload("res://addons/intervals/editor/event_node.gd")
const MultiEventCreateEvent = preload("res://addons/intervals/editor/multi_event_create_event.gd")
const MultiEventEditor = preload("res://addons/intervals/editor/multi_event_editor.gd")

const EVENT_NODE = preload("res://addons/intervals/editor/event_node.tscn")

@onready var multi_event_editor: MultiEventEditor = get_parent()
@onready var multi_event_create_event: MultiEventCreateEvent = $MultiEventCreateEvent

@export var multi_event: MultiEvent:
	set(x):
		if multi_event:
			multi_event.editor_refresh.disconnect(refresh)
		multi_event = x
		selected_nodes = []
		if multi_event:
			multi_event.editor_refresh.connect(refresh)
		if is_node_ready():
			refresh()
			_recenter()

var event_to_node := {}
var event_nodes: Array[EventNode] = []
var selected_nodes: Array[EventNode] = []

var event_clipboard := {}
var clipboard_pos := Vector2.ZERO

func _ready() -> void:
	## Signals from Signals Dot Com
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
	multi_event_create_event.new_event.connect(new_event)

func _connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	var from_event_node: EventNode = get_node(NodePath(from_node))
	var to_event_node: EventNode = get_node(NodePath(to_node))
	multi_event.connect_events(from_event_node.event, to_event_node.event, from_port)

func _connection_from_empty(to_node: StringName, to_port: int, release_position: Vector2):
	var pos := (release_position + scroll_offset) / zoom
	var event: Event = get_node(NodePath(to_node)).event
	multi_event_create_event.activate_from_empty(pos, event)

func _connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2):
	var pos := (release_position + scroll_offset) / zoom
	var event: Event = get_node(NodePath(from_node)).event
	multi_event_create_event.activate_to_empty(pos, event, from_port)

func _disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	var from_event_node: EventNode = get_node(NodePath(from_node))
	var to_event_node: EventNode = get_node(NodePath(to_node))
	multi_event.disconnect_events(from_event_node.event, to_event_node.event, from_port)

func _copy_nodes_request():
	event_clipboard = {}
	clipboard_pos = scroll_offset
	for node in selected_nodes:
		event_clipboard[node.event.duplicate()] = node.position_offset - clipboard_pos

func _paste_nodes_request():
	for node in selected_nodes.duplicate():
		node.set_selected(false)
	var old_clipboard := event_clipboard.duplicate()
	event_clipboard = {}
	for event in old_clipboard:
		new_event(event, old_clipboard[event] - clipboard_pos + (scroll_offset * 2))
		event_to_node[event].set_selected(true)
		event_clipboard[event.duplicate()] = old_clipboard[event]

func _delete_nodes_request(nodes: Array[StringName]):
	for node_name in nodes:
		var node: Node = get_node(NodePath(node_name))
		if node is EventNode:
			delete_event(node.event)

func _duplicate_nodes_request():
	for node in selected_nodes.duplicate():
		var event: Event = node.event
		var idx := multi_event.events.find(event)
		var event_dupe := event.duplicate()
		new_event(event_dupe, Vector2i(node.position_offset))
		node.set_selected(false)
		event_to_node[event_dupe].set_selected(true)

func _end_node_move():
	for node in event_nodes:
		multi_event.set_event_editor_position(node.event, node.position_offset + scroll_offset)

func _node_selected(node: Node):
	if node is EventNode:
		selected_nodes.append(node)

func _node_deselected(node: Node):
	if node is EventNode:
		selected_nodes.erase(node)

func _popup_request(at_position: Vector2):
	multi_event_create_event.activate((at_position + scroll_offset) / zoom)

func new_event(event: Event, position: Vector2i):
	while true:
		for n in event_nodes:
			if n.position_offset.is_equal_approx(position):
				position += Vector2i(32, 32)
				continue
		break
	multi_event.add_event(event, position)

func delete_event(event: Event):
	multi_event.remove_event(event)

func refresh():
	if not multi_event:
		## Cleanup.
		clear_connections()
		for event_node in event_nodes.duplicate():
			event_node.queue_free()
		event_to_node = {}
		event_nodes = []
	else:
		## Delete un-accounted for nodes.
		var existing_events := {}
		for event_node in event_nodes.duplicate():
			if event_node.event not in multi_event.events:
				selected_nodes.erase(event_node)
				event_nodes.erase(event_node)
				event_node.queue_free()
			else:
				existing_events[event_node.event] = null
		
		## Create missing nodes.
		for event in multi_event.events:
			if event not in existing_events:
				var event_node := EVENT_NODE.instantiate()
				event_node.event = event
				event_to_node[event] = event_node
				event_nodes.append(event_node)
				event_node.request_delete.connect(_event_node_request_delete)
				event_node.inspect_event.connect(_event_node_inspect_event)
				add_child(event_node)
				event_node.position_offset = multi_event.event_positions.get(event, Vector2i.ZERO)
		
		## Rebuild connections.
		## Dictionary[Event, Dict[int, Array[Event]]]
		for event: Event in multi_event.event_connections:
			var branch_dict: Dictionary = multi_event.event_connections[event]
			for branch_idx: int in branch_dict:
				var slot_idx := branch_idx
				for to_event: Event in branch_dict[branch_idx]:
					connect_node(event_to_node[event].name, slot_idx, event_to_node[to_event].name, 0)
		
		## Keep create node at the end.
		move_child(multi_event_create_event, -1)

func _event_node_request_delete(event: Event):
	multi_event.remove_event(event)

func _event_node_inspect_event(event: Event):
	EditorInterface.inspect_object(event)
	if event is MultiEvent:
		multi_event_editor.multi_event = event

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cut") and selected_nodes:
		event_clipboard = {}
		for node in selected_nodes.duplicate():
			event_clipboard[node.event] = node.position_offset - scroll_offset
			delete_event(node.event)
		clipboard_pos = scroll_offset
		accept_event()

func _recenter():
	zoom = 1.0
	await get_tree().process_frame
	if not event_nodes:
		scroll_offset = Vector2.ZERO
		return
	var average_node_position := Vector2.ZERO
	for node in event_nodes:
		average_node_position += node.position_offset + (node.size / 2)
	average_node_position /= event_nodes.size()
	scroll_offset = average_node_position - (size / 2)

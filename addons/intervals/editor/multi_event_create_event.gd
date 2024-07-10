@tool
extends GraphElement

const MultiEventGraphEdit = preload("res://addons/intervals/editor/multi_event_graph_edit.gd")

const EVENT = preload("res://addons/intervals/icons/event.png")
const DELIMITER = "/"

signal new_event(event: Event, position: Vector2i)

# @onready var scroll_container: ScrollContainer = $Panel/ScrollContainer
@onready var tree: Tree = $Panel/Tree

var multi_event_graph_edit: MultiEventGraphEdit:
	get: return get_parent()
var multi_event: MultiEvent:
	get: return multi_event_graph_edit.multi_event

@onready var _zoom_max: float = multi_event_graph_edit.zoom_max
@onready var _zoom_min: float = multi_event_graph_edit.zoom_min

var mouse_inside: bool:
	get:
		return get_global_rect().has_point(get_global_mouse_position())

var activation_mode := 0
var activation_event: Event = null
var activation_branch: = 0

var spawned_elements: Array = []

var item_to_event_class := {}

func _ready() -> void:
	hide()
	tree.item_activated.connect(_tree_item_activated)

func activate(pos: Vector2i):
	activation_mode = 0
	position_offset = pos
	refresh()
	show()

func activate_from_empty(pos: Vector2i, to_event: Event):
	activate(pos)
	activation_mode = 1
	activation_event = to_event

func activate_to_empty(pos: Vector2i, to_event: Event, branch_idx: int):
	activate(pos)
	activation_mode = 2
	activation_event = to_event
	activation_branch = branch_idx

func deactivate():
	hide()
	activation_mode = 0
	activation_event = null
	activation_branch = 0

func _process(delta: float) -> void:
	if is_visible_in_tree() and mouse_inside:
		multi_event_graph_edit.zoom_max = multi_event_graph_edit.zoom
		multi_event_graph_edit.zoom_min = multi_event_graph_edit.zoom
	else:
		multi_event_graph_edit.zoom_max = _zoom_max
		multi_event_graph_edit.zoom_min = _zoom_min

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_visible_in_tree() \
		and not mouse_inside and event.is_pressed() \
		and event.button_index == MOUSE_BUTTON_LEFT:
		deactivate()

## Refreshes the button and label list.
func refresh():
	# Setup refresh.
	var event_classes := get_event_classes()
	tree.clear()
	
	# Determined the nested header dict.
	var header_paths := {}
	for event_class_name in event_classes:
		var event_class: Script = event_classes[event_class_name]
		var category: String = event_class.get_editor_category()
		if not category:
			continue
		
		# Define the header path for this category.
		var category_path := category.split(DELIMITER)
		var curr_dict := header_paths
		while category_path.size():
			curr_dict = curr_dict.get_or_add(category_path[0], {})
			category_path.remove_at(0)
	
	# Build the header items.
	var tree_root := tree.create_item()
	tree_root.set_text(0, "Events")
	header_paths[""] = {}
	var category_path_to_tree_item := {}
	_recusrive_make_category_items(header_paths, category_path_to_tree_item, tree_root)
	
	# print(tree.get_)
	
	# Create all category for events groups.
	var groups := {}
	for event_class_name in event_classes:
		var event_class: Script = event_classes[event_class_name]
		var category: String = event_class.get_editor_category()
		groups.get_or_add(category, []).append([event_class.get_editor_name(), event_class_name])
	for group_array: Array in groups.values():
		group_array.sort_custom(func (a, b): return a[0] < b[0])
	
	# Build all tree items now.
	item_to_event_class = {}
	for category in groups:
		for event_data: Array in groups[category]:
			# Create and setup tree item.
			var tree_item := tree.create_item(category_path_to_tree_item.get(category))
			var event_class: GDScript = event_classes[event_data[1]]
			tree_item.set_icon(0, EVENT)
			tree_item.set_icon_max_width(0, 16)
			tree_item.set_icon_modulate(0, event_class.get_editor_color())
			tree_item.set_text(0, event_data[0])
			
			# Setup event class mapping.
			item_to_event_class[tree_item] = event_class
	
func _tree_item_activated():
	var item: TreeItem = tree.get_selected()
	if item in item_to_event_class:
		_on_create_event_pressed(item_to_event_class[item])

func _on_create_event_pressed(event_class: Script):
	var event: Event = event_class.new()
	new_event.emit(event, Vector2i(position_offset))
	match activation_mode:
		1:
			## Connect from-empty
			multi_event.connect_events(event, activation_event, 0)
		2:
			## Connect to-empty
			multi_event.connect_events(activation_event, event, activation_branch)
	deactivate()

## Returns a dictionary of all event classes that can be created.
static func get_event_classes() -> Dictionary:
	var global_class_list := ProjectSettings.get_global_class_list()
	var ret_dict := {}
	var last_result := -1
	while last_result != ret_dict.size():
		last_result = ret_dict.size()
		for item in global_class_list:
			if item['class'] in ret_dict:
				continue
			if item['base'] in ret_dict or item['class'] == &"Event":
				var event_class := load(item['path'])
				if not event_class._editor_can_be_created():
					continue
				ret_dict[item['class']] = event_class
	return ret_dict

func _recusrive_make_category_items(header_paths: Dictionary, out: Dictionary, parent: TreeItem = null, path: String = ""):
	# Get all of the headers for this dictionary.
	var headers: Array = header_paths.keys()
	headers.sort()
	
	# Create a tree item for each header.
	for header: String in headers:
		var category_path := header if not path else path + DELIMITER + header
		var tree_item: TreeItem = parent
		if category_path:
			tree_item = tree.create_item(parent)
			tree_item.set_text(0, header)
			tree_item.collapsed = true
		
		out[category_path] = tree_item
		_recusrive_make_category_items(header_paths[header], out, tree_item, category_path)

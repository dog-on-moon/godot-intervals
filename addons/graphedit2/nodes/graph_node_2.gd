@tool
extends GraphNode
class_name GraphNode2

## The node resource associated with the GraphNode.
## Must be a GraphNodeResource or otherwise implement its traits.
@export var resource: Resource:
	set(x):
		if not x or GraphNodeResource.validate_implementation(x):
			resource = x
			_update_appearance()

@onready var graph_edit: GraphEdit2 = get_parent()

var connection_labels: Array[Label] = []

var inspect_button: Button
var close_button: Button

func _ready() -> void:
	# Set header label to fill real quick
	#var title_bar := get_titlebar_hbox()
	#var header_label: Label = get_titlebar_hbox().get_child(0)
	#header_label.size_flags_horizontal = SIZE_FILL + SIZE_EXPAND
	
	inspect_button = _add_titlebar_button(1, "I")
	inspect_button.pressed.connect(func (): EditorInterface.edit_resource(resource))
	close_button = _add_titlebar_button(2, "X")
	close_button.pressed.connect(func (): graph_edit.remove_resource(resource))

## Adds a button to the titlebar.
func _add_titlebar_button(index: int, text: String = "", icon: Texture2D = null) -> Button:
	# Create button.
	var button := Button.new()
	button.text = text
	button.icon = icon
	
	# Add to titlebar.
	var title_bar := get_titlebar_hbox()
	button.custom_minimum_size = Vector2(title_bar.size.y, 0)
	title_bar.add_child(button)
	title_bar.move_child(button, index)
	return button

## Called to update the visual properties of our node.
func _update_appearance():
	if resource:
		## Setup node title.
		if title != resource.get_graph_frame_title():
			title = resource.get_graph_node_title()
			var style_box := _get_title_bar_stylebox()
			style_box.bg_color = resource.get_graph_node_color() * 0.7
			var selected_style_box := _get_title_bar_stylebox()
			selected_style_box.bg_color = resource.get_graph_node_color() * 0.85
			add_theme_stylebox_override(&"titlebar", style_box)
			add_theme_stylebox_override(&"titlebar_selected", selected_style_box)
		
		## Create new connection labels.
		var connection_count := get_connection_count()
		for i in range(connection_count - connection_labels.size()):
			var idx := connection_count + i
			var label := _make_connection_label(idx)
			connection_labels.append(label)
			add_child(label)
		
		## Remove old labels.
		for i in range(connection_labels.size() - connection_count):
			var label := connection_labels.pop_back()
			label.queue_free()
		
		## Update all labels.
		for i in connection_labels.size():
			_update_label(connection_labels[i], i)
	else:
		## Cleanup node title.
		title = ""
		remove_theme_stylebox_override(&"titlebar")
		remove_theme_stylebox_override(&"titlebar_selected")

## Called to create a connection label.
func _make_connection_label(idx := 0) -> Control:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(0, 15)
	label.text = "#%s" % idx
	return label

## Called to update a connection label.
func _update_label(label: Label, idx := 0):
	var inbound_connections: int = resource.get_inbound_connections()
	var outbound_connections: int = resource.get_outbound_connections()
	set_slot(idx, idx < inbound_connections, 0, Color.WHITE, idx < outbound_connections, 0, Color.WHITE, null, null, false)

## Returns the number of connection labels present.
func get_connection_count() -> int:
	if not resource:
		return 0
	return max(resource.get_inbound_connections(), resource.get_outbound_connections())

## Returns the stylebox for the title bar.
static func _get_title_bar_stylebox() -> StyleBox:
	return preload("res://addons/graphedit2/nodes/graph_node_2_titlebar_stylebox.tres").duplicate()

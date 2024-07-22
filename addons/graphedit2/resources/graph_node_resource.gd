@icon("res://addons/graphedit2/icons/ResGraphNode.png")
@tool
extends GraphElementResource
class_name GraphNodeResource
## A resource for information within a GraphNode.

var _graph_node_text_label: RichTextLabel = null
var _padding: Control = null

## Returns the title of the GraphNode.
static func get_graph_node_title() -> String:
	return "GraphNode"

## The base description that appears on the GraphNode.
## When defined, a RichTextLabel is created according to our base ready.
func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	return ""

## Returns the color of the GraphNode.
static func get_graph_node_color() -> Color:
	return Color.WHITE

## Returns the minimum width of this graph node.
static func get_graph_node_width() -> int:
	return 80

## Returns the number of input connections.
func get_input_connections() -> int:
	return 0

## Returns the number of output connections.
func get_output_connections() -> int:
	return 0

func _editor_ready(edit: GraphEdit, element: GraphElement):
	super(edit, element)
	
	if _editor_make_node_controls():
		var desc := get_graph_node_description(edit, element)
		_graph_node_text_label = RichTextLabel.new()
		_graph_node_text_label.bbcode_enabled = true
		_graph_node_text_label.fit_content = true
		_graph_node_text_label.text = desc
		_graph_node_text_label.visible = desc != ""
		_graph_node_text_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		_graph_node_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		element.add_child(_graph_node_text_label)
		element.move_child(_graph_node_text_label, 0)
		
		_padding = Control.new()
		_padding.size = Vector2.ZERO
		_padding.custom_minimum_size = Vector2(get_graph_node_width(), 3)
		_padding.mouse_filter = Control.MOUSE_FILTER_IGNORE
		element.add_child(_padding)

func _editor_process(edit: GraphEdit, element: GraphElement):
	if _graph_node_text_label and is_instance_valid(_graph_node_text_label):
		var desc := get_graph_node_description(edit, element)
		if _graph_node_text_label.text != desc:
			_graph_node_text_label.text = desc
		# We force the visibility of the text label when there's a description,
		# or when there's a handful of connections present -- this is because
		# GraphNode has issues placing ports on the right nodes when there's
		# invisible children, so this label must be visible.
		_graph_node_text_label.visible = (desc != "") or (
			max(get_input_connections(), get_output_connections()) >= 2
		)
	if _padding and _padding != element.get_child(element.get_child_count() - 1):
		element.move_child(_padding, -1)

static func get_graph_dropdown_icon_modulate(script: Script = null) -> Color:
	return script.get_graph_node_color() if script else get_graph_node_color()

func _editor_make_node_controls() -> bool:
	return true

func _make_graph_control() -> Control:
	return GraphNode2.new()

func _to_string() -> String:
	return resource_name if resource_name else get_graph_node_title()

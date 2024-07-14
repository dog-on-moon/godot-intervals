@icon("res://addons/graphedit2/icons/ResGraphNode.png")
@tool
extends GraphElementResource
class_name GraphNodeResource
## A resource for information within a GraphNode.

var _graph_node_text_label: RichTextLabel = null
var _padding: Control = null

static func get_graph_args() -> Dictionary:
	return super().merged({
		## The title of the GraphNode.
		"title": "GraphNode",
		
		## The minimum width of the GraphNode.
		"node_min_width": 80,
		
		## Determines if we make custom text label node controls.
		"make_node_controls": true,
	})

## The base description that appears on the GraphNode.
## When defined, a RichTextLabel is created according to our base ready.
func get_graph_node_description(_edit: GraphEdit2, _element: GraphElement) -> String:
	return ""

## Returns the number of input connections.
func get_input_connections() -> int:
	return 0

## Returns the number of output connections.
func get_output_connections() -> int:
	return 0

func _editor_ready(edit: GraphEdit2, element: GraphElement):
	super(edit, element)
	
	if _args['make_node_controls']:
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
		_padding.custom_minimum_size = Vector2(_args['node_min_width'], 3)
		_padding.mouse_filter = Control.MOUSE_FILTER_IGNORE
		element.add_child(_padding)

func _editor_process(edit: GraphEdit2, element: GraphElement):
	if _graph_node_text_label and is_instance_valid(_graph_node_text_label):
		var desc := get_graph_node_description(edit, element)
		if _graph_node_text_label.text != desc:
			_graph_node_text_label.text = desc
			_graph_node_text_label.visible = desc != ""
	if _padding and _padding != element.get_child(element.get_child_count() - 1):
		element.move_child(_padding, -1)

func _make_graph_control() -> Control:
	return GraphNode2.new()

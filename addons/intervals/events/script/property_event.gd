@tool
extends Event
class_name PropertyEvent
## Sets a property on a node.

@export_node_path("Node") var node_path: NodePath = ^"":
	set(x):
		node_path = x
		if _node_button:
			_node_button.visible = _object_exists()
@export var property: String = "":
	set(x):
		property = x
		if _node_button:
			_node_button.visible = _object_exists()

var node: Node:
	get: return _editor_owner.get_node_or_null(node_path) if node_path and _editor_owner else null

var _node_button: Button = null
var _editor_owner: Node = null

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var node: Node = _owner.get_node(node_path)
	assert(property in node)
	return Sequence.new([
		Func.new(func (): node[property] = get_value()),
		Func.new(done.emit)
	])

func get_value() -> Variant:
	return null

#region Base Editor Overrides
static func get_graph_dropdown_category() -> String:
	return "Script"

static func get_graph_node_title() -> String:
	return "Property"

func get_graph_node_description(_edit: GraphEdit, _element: GraphElement) -> String:
	return (("%s.%s = %s" % [
		get_node_path_string(_editor_owner, node_path), property, get_value()
	]) if property in node else ("[b][color=red]Invalid Property")
	) if _object_exists() else ("[b][color=red]Invalid Object")

static func get_graph_node_color() -> Color:
	return FuncEvent.get_graph_node_color()

func _editor_ready(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	_editor_owner = get_editor_owner(_edit)
	_node_button = _element._add_titlebar_button(1, "", preload("res://addons/graphedit2/icons/Object.png"))
	_node_button.pressed.connect(_on_inspect)
	_node_button.visible = _object_exists()

func _editor_process(_edit: GraphEdit, _element: GraphElement):
	pass
	# print(get_property_list())
#endregion

#region Property Internal
func _object_exists() -> bool:
	return node != null

func _on_inspect():
	if node:
		EditorInterface.inspect_object(node)

#endregion

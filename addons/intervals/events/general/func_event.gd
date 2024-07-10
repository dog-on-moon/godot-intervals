@tool
extends Event
class_name FuncEvent
## Calls a function on a node.

@export_node_path("Node") var node_path: NodePath = ^"":
	set(x):
		node_path = x
		if _script_button:
			_script_button.visible = _editor_script_exists()
@export var function_name: String = "":
	set(x):
		function_name = x
		if _script_button:
			_script_button.visible = _editor_script_exists()
@export var args: Array = []

var _script_button: Button = null
var _editor_owner: Node = null

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var node: Node = _owner.get_node(node_path)
	assert(function_name in node)
	var callable: Callable = node[function_name]
	return Sequence.new([
		Func.new(callable.bindv(args)),
		Func.new(done.emit)
	])

func get_branch_names() -> Array:
	return ["Default"]

static func get_editor_color() -> Color:
	return Color(0.922, 0.749, 0.549, 1.0)

static func get_editor_name() -> String:
	return "Callable"

func get_editor_description_text(_owner: Node) -> String:
	return ("%s.%s(%s)" % [get_node_path_string(_owner, node_path), function_name, args]) if _editor_script_exists() else ("[b][color=red]Invalid Callable")

static func get_editor_category() -> String:
	return "General"

func _editor_setup(_owner: Node, _info_container: EventEditorInfoContainer):
	_editor_owner = _owner
	_script_button = _editor_make_script_button(
		func (): return _editor_get_target_node(node_path, _owner),
		func (): return _editor_get_substring(),
		_info_container
	)

func _editor_script_exists() -> bool:
	return _editor_find_node_script(
		_editor_get_substring(),
		_editor_get_target_node(node_path, _editor_owner)
	)

func _editor_get_substring():
	return "func %s(" % function_name

static func _editor_make_script_button(node_func: Callable, substr_func: Callable, _info_container: EventEditorInfoContainer, script_search_func := _editor_find_node_script) -> Button:
	var script_button := _info_container.add_new_button("Open Script", 1)
	script_button.pressed.connect(func ():
		script_search_func.call(substr_func.call(), node_func.call(), true)
	)
	script_button.visible = script_search_func.call(substr_func.call(), node_func.call())
	return script_button

static func _editor_find_node_script(substr: String, node: Node, open := false) -> bool:
	if node and node.get_script():
		var lines: PackedStringArray = node.get_script().source_code.split('\n')
		for i in lines.size():
			var line: String = lines[i]
			if line.find(substr) != -1:
				if open:
					EditorInterface.set_main_screen_editor("Script")
					EditorInterface.edit_script(node.get_script(), i + 1)
				return true
	return false

static func _editor_get_target_node(np: NodePath, _owner: Node) -> Node:
	if np and _owner:
		return _owner.get_node_or_null(np)
	return null

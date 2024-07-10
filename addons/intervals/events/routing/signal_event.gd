@tool
extends Event
class_name SignalEvent
## An event that emits done after a node's signal has been raised.
## Easy to mix up with EmitEvent (sorry!)

@export_node_path("Node") var node_path: NodePath = ^"":
	set(x):
		node_path = x
		if _script_button:
			_script_button.visible = _editor_script_exists()
@export var signal_name: StringName = &"":
	set(x):
		signal_name = x
		if _script_button:
			_script_button.visible = _editor_script_exists()

var _script_button: Button = null
var _editor_owner: Node = null

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var node: Node = _owner.get_node(node_path)
	return Func.new(connect_signal.bind(node))

func connect_signal(node: Node):
	node.connect(signal_name, done.emit, CONNECT_ONE_SHOT)

static func get_editor_color() -> Color:
	return Color(0.8, 0.545, 0.376, 1.0)

static func get_editor_name() -> String:
	return "Await Signal"

func get_editor_description_text(_owner: Node) -> String:
	return ("%s %s.%s()" % [_get_editor_description_prefix(), get_node_path_string(_owner, node_path), signal_name]) if _editor_script_exists() else ("[b][color=red]Invalid Signal")

func _get_editor_description_prefix() -> String:
	return "Awaiting"

static func get_editor_category() -> String:
	return "Routing"

func _editor_setup(_owner: Node, _info_container: EventEditorInfoContainer):
	_editor_owner = _owner
	_script_button = FuncEvent._editor_make_script_button(
		func (): return FuncEvent._editor_get_target_node(node_path, _owner),
		func (): return _editor_get_substring(),
		_info_container,
		_editor_find_node_script
	)

func _editor_script_exists() -> bool:
	return _editor_find_node_script(
		_editor_get_substring(),
		FuncEvent._editor_get_target_node(node_path, _editor_owner)
	)

func _editor_get_substring():
	return "signal %s" % signal_name

# custom script search function to look for signals more cleanly
static func _editor_find_node_script(substr: String, node: Node, open := false) -> bool:
	if node and node.get_script():
		var lines: PackedStringArray = node.get_script().source_code.split('\n')
		for i in lines.size():
			var line: String = lines[i]
			if line == substr or line.find(substr + "(") != -1:
				if open:
					EditorInterface.set_main_screen_editor("Script")
					EditorInterface.edit_script(node.get_script(), i + 1)
				return true
	return false
#endregion

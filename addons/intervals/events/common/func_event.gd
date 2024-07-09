@tool
extends Event
class_name FuncEvent

@export_node_path("Node") var node_path: NodePath
@export var function_name: String
@export var args: Array = []

func _get_interval(owner: Node, state: Dictionary) -> Interval:
	var node: Node = owner.get_node(node_path)
	assert(function_name in node)
	var callable: Callable = node[function_name]
	return Sequence.new([
		Func.new(callable.bindv(args)),
		Func.new(done.emit)
	])

func get_branch_names() -> Array:
	return ["Default"]

#region Editor Overrides
## The color that represents this event in the editor.
static func get_editor_color() -> Color:
	return Color(0.922, 0.749, 0.549, 1.0)

## String representation of the event. Important to define.
static func get_editor_name() -> String:
	return "FuncEvent"

## The editor description of the event.
func get_editor_description_text(owner: Node) -> String:
	return "%s\n[b]Callable:[/b] %s\n[b]Arguments: [/b] %s" % [
		get_node_path_string(owner, node_path),
		function_name if function_name else "undefined", args
	]

## The editor category that the event belongs to.
static func get_editor_category() -> String:
	return "General"

## Set up the editor info container.
## This is the Control widget that appears within the Event nodes (above the connections).
func setup_editor_info_container(owner: Node, info_container: EventEditorInfoContainer):
	info_container.add_new_button("Open Script", 1).pressed.connect(func ():
		if node_path:
			var node := owner.get_node_or_null(node_path)
			print(node)
			if node and node.get_script():
				EditorInterface.set_main_screen_editor("Script")
				EditorInterface.edit_script(node.get_script())
	)
#endregion

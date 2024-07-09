@tool
extends Event
class_name SignalEvent
## An event that emits done after a node's signal has been raised.

@export_node_path("Node") var node_path: NodePath = ^""
@export var signal_name: StringName = &""

func _get_interval(owner: Node, state: Dictionary) -> Interval:
	var node: Node = owner.get_node(node_path)
	return Func.new(connect_signal.bind(node))

func connect_signal(node: Node):
	node.connect(signal_name, done.emit, CONNECT_ONE_SHOT)

#region Editor Overrides
static func get_editor_color() -> Color:
	return Color(0.8, 0.545, 0.376, 1.0)

## String representation of the event. Important to define.
static func get_editor_name() -> String:
	return "SignalEvent"

## The editor description of the event.
func get_editor_description_text(owner: Node) -> String:
	var valid_np := node_path and owner and owner.get_node_or_null(node_path)
	return "[b]%s\nAwaits Signal:[/b] %s" % [
		node_path if valid_np else "[color=red]Invalid NodePath[/color]",
		signal_name if signal_name else "undefined"
	]

## The editor category that the event belongs to.
static func get_editor_category() -> String:
	return "Meta"

## Set up the editor info container.
## This is the Control widget that appears within the Event nodes (above the connections).
func setup_editor_info_container(owner: Node, info_container: EventEditorInfoContainer):
	info_container.add_new_button("Open Script", 1).pressed.connect(func ():
		if node_path:
			var node := owner.get_node_or_null(node_path)
			if node and node.get_script():
				EditorInterface.set_main_screen_editor("Script")
				EditorInterface.edit_script(node.get_script())
	)
#endregion

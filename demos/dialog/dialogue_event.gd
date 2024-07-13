@tool
extends Event
class_name DialogueEvent
## An example event showing how to customize dialogue for the Event Editor.

const DIALOGUE_BOX = preload("res://demos/dialog/dialogue_box.tscn")

@export_multiline var text := ""

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var dc: DialogueContainer = DialogueContainer.singleton
	return Sequence.new([
		Connect.new(dc.dialogue_complete, done.emit, CONNECT_ONE_SHOT),
		Func.new(dc.add_text.bind(text)),
	])

#region Base Editor Overrides
var _editor_dialogue_box: DialogueBox

static func get_graph_dropdown_category() -> String:
	return "Demo/Dialogue"

static func get_graph_node_title() -> String:
	return "Dialogue"

static func get_graph_node_color() -> Color:
	return Color(0.353, 0.537, 0.298, 1.0)

func _editor_ready(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	_editor_dialogue_box = DIALOGUE_BOX.instantiate()
	_element.add_child(_editor_dialogue_box)
	_editor_dialogue_box.text = text

func _editor_process(_edit: GraphEdit, _element: GraphElement):
	super(_edit, _element)
	if _editor_dialogue_box.text != text:
		_editor_dialogue_box.text = text
#endregion

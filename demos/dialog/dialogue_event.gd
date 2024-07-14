@tool
extends Event
class_name DialogueEvent
## An example event showing how to customize dialogue for the Event Editor.

const DIALOGUE_BOX = preload("res://demos/dialog/dialogue_box.tscn")

@export_multiline var text := ""

var _editor_dialogue_box: DialogueBox

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var dc: DialogueContainer = DialogueContainer.singleton
	return Sequence.new([
		Connect.new(dc.dialogue_complete, done.emit, CONNECT_ONE_SHOT),
		Func.new(dc.add_text.bind(text)),
	])

static func get_graph_args() -> Dictionary:
	return super().merged({
		"title": "Dialogue",
		"category": "Demo/Dialogue",
		"modulate": Color(0.353, 0.537, 0.298, 1.0),
		"node_min_width": 0,
	})

func _editor_ready(_edit: GraphEdit2, _element: GraphElement):
	super(_edit, _element)
	_editor_dialogue_box = DIALOGUE_BOX.instantiate()
	_element.add_child(_editor_dialogue_box)
	_editor_dialogue_box.text = text

func _editor_process(_edit: GraphEdit2, _element: GraphElement):
	super(_edit, _element)
	if _editor_dialogue_box.text != text:
		_editor_dialogue_box.text = text

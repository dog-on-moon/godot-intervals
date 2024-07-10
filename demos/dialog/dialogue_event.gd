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

static func get_editor_color() -> Color:
	return Color(0.353, 0.537, 0.298, 1.0)

static func get_editor_name() -> String:
	return "Dialogue"

static func get_editor_category() -> String:
	return "Demo/Dialogue"

var _editor_dialogue_box: DialogueBox

func _editor_setup(_owner: Node, _info_container: EventEditorInfoContainer):
	_editor_dialogue_box = DIALOGUE_BOX.instantiate()
	_info_container.add_child(_editor_dialogue_box)
	_info_container.move_child(_editor_dialogue_box, 0)
	_editor_dialogue_box.text = text

func _editor_process(_owner: Node, _info_container: EventEditorInfoContainer) -> bool:
	var old_size := _editor_dialogue_box.custom_minimum_size
	_editor_dialogue_box.text = text
	return not _editor_dialogue_box.custom_minimum_size.is_equal_approx(old_size)

func _editor_get_panel_size() -> Vector2:
	return Vector2(DialogueBox.DIALOGUE_SIZE.x, DialogueBox.DIALOGUE_SIZE.y * (1 + text.count('\n')))

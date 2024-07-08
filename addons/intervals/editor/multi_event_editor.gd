@tool
extends VSplitContainer
class_name MultiEventEditor
## The editor for MultiEvents.

@onready var header: HBoxContainer = $Header
@onready var graph_edit: MultiEventGraphEdit = $GraphEdit
@onready var label: Label = $Label

@onready var up_event_button: Button = $Header/UpEventButton
@onready var up_event_label: Label = $Header/UpEventLabel
@onready var event_name_edit: TextEdit = $Header/EventNameEdit
@onready var warning_spacing: Label = $Header/WarningSpacing
@onready var option_button: OptionButton = $Header/OptionButton

@onready var debug_box: CheckBox = $Header/DebugBox

@export var multi_event: MultiEvent:
	set(x):
		if multi_event == x:
			return
		multi_event = x
		if is_node_ready():
			graph_edit.multi_event = x
			header.visible = x != null
			graph_edit.visible = x != null
			label.visible = x == null

@export var event_owner: Node

func _ready() -> void:
	# theme = EditorInterface.get_editor_theme()
	multi_event = multi_event
	
	debug_box.toggled.connect(func (x: bool): multi_event.debug = x)
	option_button.item_selected.connect(func (x: int): multi_event.complete_mode = x)

func _process(delta: float) -> void:
	if multi_event:
		if debug_box.button_pressed != multi_event.debug:
			debug_box.button_pressed = multi_event.debug
		if option_button.selected != multi_event.complete_mode:
			option_button.selected = multi_event.complete_mode

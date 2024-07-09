@tool
extends Control
## The editor for MultiEvents.

const MultiEventGraphEdit = preload("res://addons/intervals/editor/multi_event_graph_edit.gd")
const MULTI_EVENT_GRAPH_EDIT = preload("res://addons/intervals/editor/multi_event_graph_edit.tscn")

@onready var header: HBoxContainer = $Header
@onready var tab_container: TabContainer = $TabContainer

@onready var graph_edit: MultiEventGraphEdit = $GraphEdit
@onready var label: Label = $Label

@onready var up_event_button: Button = $Header/UpEventButton
@onready var up_event_label: Label = $Header/UpEventLabel
@onready var event_name_edit: TextEdit = $Header/EventNameEdit
@onready var warning_spacing: Label = $Header/WarningSpacing
@onready var option_button: OptionButton = $Header/OptionButton

@onready var debug_box: CheckBox = $Header/DebugBox

var multi_event_stack: Array[MultiEvent] = []

@export var multi_event: MultiEvent:
	set(x):
		if multi_event == x:
			return
		
		if multi_event_stack and x == multi_event_stack[-1]:
			multi_event_stack.pop_back()
			_update_event_stack()
		elif multi_event and x in multi_event.events:
			multi_event_stack.append(multi_event)
			_update_event_stack()
		else:
			multi_event_stack = []
			_update_event_stack()
		
		multi_event = x
		
		if is_node_ready():
			graph_edit.multi_event = x
			event_name_edit.text = x.resource_name if x else ""
			header.visible = x != null
			graph_edit.visible = x != null
			label.visible = x == null

var event_owner: Node:
	get(): return get_tree().edited_scene_root

func _ready() -> void:
	multi_event = multi_event
	
	theme = EditorInterface.get_editor_theme()
	
	debug_box.toggled.connect(func (x: bool): multi_event.debug = x)
	option_button.item_selected.connect(func (x: int): multi_event.complete_mode = x)
	up_event_button.pressed.connect(func (): up_event_stack())
	event_name_edit.text_changed.connect(func (): multi_event.resource_name = event_name_edit.text)

func up_event_stack():
	if multi_event_stack:
		multi_event = multi_event_stack[-1]

func _update_event_stack():
	if multi_event_stack:
		up_event_button.show()
		up_event_label.show()
		var txt := " "
		for multi_event in multi_event_stack:
			txt += multi_event.to_string() + " > "
		up_event_label.text = txt
	else:
		up_event_button.hide()
		up_event_label.hide()

func _process(delta: float) -> void:
	if multi_event:
		if debug_box.button_pressed != multi_event.debug:
			debug_box.button_pressed = multi_event.debug
		if option_button.selected != multi_event.complete_mode:
			option_button.selected = multi_event.complete_mode
		if event_name_edit.text != multi_event.resource_name:
			event_name_edit.text = multi_event.resource_name
		if event_name_edit.placeholder_text != multi_event.get_editor_name():
			event_name_edit.placeholder_text = multi_event.get_editor_name()

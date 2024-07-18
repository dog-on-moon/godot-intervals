@tool
extends EditorPlugin
## Intervals by dog.on.moon
## Developer-friendly Tweens packaged with a simple, powerful, expandable cutscene editor.
## [dependent on graphedit2]

const MultiEventEditor = preload("res://addons/intervals/editor/multi_event_editor.gd")

var multi_event_editor: MultiEventEditor = null
var multi_event_editor_button: Button = null

func _enter_tree():
	const EVENT_PLAYER := preload("res://addons/intervals/icons/event_player.png")
	const INTERVAL := preload("res://addons/intervals/icons/interval.png")
	const INTERVAL_CONTAINER := preload("res://addons/intervals/icons/interval_container.png")
	
	## Intervals
	add_custom_type("Interval", "RefCounted", preload("res://addons/intervals/interval/interval.gd"), INTERVAL)
	
	## Common Intervals
	add_custom_type("Connect", "Interval", preload("res://addons/intervals/interval/common/connect.gd"), INTERVAL)
	add_custom_type("Func", "Interval", preload("res://addons/intervals/interval/common/func.gd"), INTERVAL)
	add_custom_type("LerpFunc", "Interval", preload("res://addons/intervals/interval/common/lerp_func.gd"), INTERVAL)
	add_custom_type("LerpProperty", "Interval", preload("res://addons/intervals/interval/common/lerp_property.gd"), INTERVAL)
	add_custom_type("Wait", "Interval", preload("res://addons/intervals/interval/common/wait.gd"), INTERVAL)
	
	## Container Intervals
	add_custom_type("IntervalContainer", "Interval", preload("res://addons/intervals/interval/container/interval_container.gd"), INTERVAL_CONTAINER)
	add_custom_type("Parallel", "IntervalContainer", preload("res://addons/intervals/interval/container/parallel.gd"), INTERVAL_CONTAINER)
	add_custom_type("Sequence", "IntervalContainer", preload("res://addons/intervals/interval/container/sequence.gd"), INTERVAL_CONTAINER)
	add_custom_type("SequenceRandom", "IntervalContainer", preload("res://addons/intervals/interval/container/sequence_random.gd"), INTERVAL_CONTAINER)
	
	## Nodes
	add_custom_type("EventPlayer", "Node", preload("res://addons/intervals/nodes/event_player.gd"), EVENT_PLAYER)
	
	## MultiEvent Editor
	_create_editor()
	
	## Signals
	EditorInterface.get_inspector().property_edited.connect(_property_selected)
	EditorInterface.get_inspector().property_selected.connect(_property_selected)
	EditorInterface.get_inspector().edited_object_changed.connect(_edited_object_changed)

func _exit_tree():
	## Intervals
	remove_custom_type("Interval")
	
	## Common Intervals
	remove_custom_type("Func")
	remove_custom_type("LerpFunc")
	remove_custom_type("LerpProperty")
	remove_custom_type("Wait")
	
	## Container Intervals
	remove_custom_type("IntervalContainer")
	remove_custom_type("Parallel")
	remove_custom_type("Sequence")
	remove_custom_type("SequenceRandom")
	
	## Nodes
	remove_custom_type("EventPlayer")
	
	## MultiEvent Editor
	_cleanup_editor()
	
	## Signals
	EditorInterface.get_inspector().property_edited.disconnect(_property_selected)
	EditorInterface.get_inspector().property_selected.disconnect(_property_selected)
	EditorInterface.get_inspector().edited_object_changed.disconnect(_edited_object_changed)

var _stored_object: WeakRef = null
var _stored_property: String = ""

func _property_selected(property: String):
	var object := EditorInterface.get_inspector().get_edited_object()
	var value := object.get(property)
	if value is MultiEvent:
		_show_editor(value)
	
	# If the property we were observing to clears out, close the editor.
	if _stored_object and _stored_object.get_ref() == object \
		and property == _stored_property and value == null:
		_hide_editor()
	
	_stored_object = weakref(object)
	_stored_property = property

func _edited_object_changed():
	var object := EditorInterface.get_inspector().get_edited_object()
	if object:
		if object is EventPlayer and object.multi_event:
			_show_editor(object.multi_event)
			_stored_object = weakref(object)
			_stored_property = "multi_event"
		elif object is MultiEvent:
			_show_editor(object)
			_stored_object = null
			_stored_property = ""
		# 4.2 backport: 'foo is not Type' isn't supported in 4.2.
		#elif object is not Event:
		elif !(object is Event):
			_hide_editor()
	else:
		_hide_editor()

func _show_editor(multi_event: MultiEvent):
	multi_event_editor.multi_event = multi_event
	if not multi_event_editor_button.visible:
		multi_event_editor_button.visible = true
		multi_event_editor_button.button_pressed = true

func _hide_editor():
	multi_event_editor_button.button_pressed = false
	multi_event_editor_button.visible = false
	multi_event_editor.multi_event = null
	_stored_object = null
	_stored_property = ""

func _create_editor():
	assert(not multi_event_editor)
	multi_event_editor = load("res://addons/intervals/editor/multi_event_editor.tscn").instantiate()
	multi_event_editor.undo_redo = get_undo_redo()
	multi_event_editor_button = add_control_to_bottom_panel(multi_event_editor, "MultiEvent")
	multi_event_editor_button.visible = false
	multi_event_editor.request_reload.connect(_reload_editor)

func _cleanup_editor():
	assert(multi_event_editor)
	remove_control_from_bottom_panel(multi_event_editor)
	multi_event_editor.queue_free()
	multi_event_editor = null

func _reload_editor():
	var state: Dictionary = multi_event_editor._get_state()
	_cleanup_editor()
	_create_editor()
	multi_event_editor._set_state(state)
	if not multi_event_editor_button.visible:
		multi_event_editor_button.visible = true
		multi_event_editor_button.button_pressed = true
		multi_event_editor.graph_edit.recenter()

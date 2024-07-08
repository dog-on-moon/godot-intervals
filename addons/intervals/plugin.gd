@tool
extends EditorPlugin

const MULTI_EVENT_EDITOR := preload("res://addons/intervals/editor/multi_event_editor.tscn")

var multi_event_editor: MultiEventEditor = null
var multi_event_editor_button: Button = null

func _enter_tree():
	const EVENT = preload("res://addons/intervals/icons/event.png")
	const INTERVAL := preload("res://addons/intervals/icons/interval.png")
	const INTERVAL_CONTAINER := preload("res://addons/intervals/icons/interval_container.png")
	
	## Intervals
	add_custom_type("Interval", "RefCounted", preload("res://addons/intervals/interval/interval.gd"), INTERVAL)
	
	## Common Intervals
	add_custom_type("Func", "Interval", preload("res://addons/intervals/interval/common/func.gd"), INTERVAL)
	add_custom_type("LerpFunc", "Interval", preload("res://addons/intervals/interval/common/lerp_func.gd"), INTERVAL)
	add_custom_type("LerpProperty", "Interval", preload("res://addons/intervals/interval/common/lerp_property.gd"), INTERVAL)
	add_custom_type("Wait", "Interval", preload("res://addons/intervals/interval/common/wait.gd"), INTERVAL)
	
	## Container Intervals
	add_custom_type("IntervalContainer", "Interval", preload("res://addons/intervals/interval/container/interval_container.gd"), INTERVAL_CONTAINER)
	add_custom_type("Parallel", "IntervalContainer", preload("res://addons/intervals/interval/container/parallel.gd"), INTERVAL_CONTAINER)
	add_custom_type("Sequence", "IntervalContainer", preload("res://addons/intervals/interval/container/sequence.gd"), INTERVAL_CONTAINER)
	add_custom_type("SequenceRandom", "IntervalContainer", preload("res://addons/intervals/interval/container/sequence_random.gd"), INTERVAL_CONTAINER)
	
	## Events
	add_custom_type("Event", "Resource", preload("res://addons/intervals/events/event.gd"), EVENT)
	add_custom_type("MultiEvent", "Event", preload("res://addons/intervals/events/multi_event.gd"), EVENT)
	
	## MultiEvent Editor
	multi_event_editor = MULTI_EVENT_EDITOR.instantiate()
	multi_event_editor_button = add_control_to_bottom_panel(multi_event_editor, "MultiEvent")
	multi_event_editor_button.visible = false
	
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
	
	## Events
	remove_custom_type("Event")
	remove_custom_type("MultiEvent")
	
	## MultiEvent Editor
	remove_control_from_bottom_panel(multi_event_editor)
	multi_event_editor.queue_free()
	
	## Signals
	EditorInterface.get_inspector().property_edited.disconnect(_property_selected)
	EditorInterface.get_inspector().property_selected.disconnect(_property_selected)
	EditorInterface.get_inspector().edited_object_changed.disconnect(_edited_object_changed)

func _property_selected(property: String):
	var object := EditorInterface.get_inspector().get_edited_object()
	var value := object.get(property)
	if value is MultiEvent:
		multi_event_editor.event_owner = object
		multi_event_editor.multi_event = value
		if not multi_event_editor_button.visible:
			multi_event_editor_button.visible = true
			multi_event_editor_button.button_pressed = true

func _edited_object_changed():
	var object := EditorInterface.get_inspector().get_edited_object()
	if object and object is not Event:
		multi_event_editor_button.button_pressed = false
		multi_event_editor_button.visible = false
		multi_event_editor.multi_event = null
		multi_event_editor.event_owner = null

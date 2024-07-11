@tool
extends GraphNode

const EventEditorInfoContainer = preload("res://addons/intervals/editor/event_editor_info_container.gd")
const MultiEventEditor = preload("res://addons/intervals/editor/multi_event_editor.gd")

signal request_delete(event: Event)
signal inspect_event(event: Event)

@onready var _info_container: EventEditorInfoContainer = $InfoContainer
@onready var rich_text_label: RichTextLabel = $InfoContainer/RichTextLabel
@onready var inspect_button: Button = $InfoContainer/Buttons/Inspect
@onready var delete_button: Button = $InfoContainer/Buttons/Delete
@onready var branch_label: Label = $Connection

@export var event: Event:
	set(x):
		if event == x:
			return
		event = x
		_has_setup_event = false
		
		if is_node_ready():
			branch_label.hide()
			update_appearance()

var branch_nodes: Array[Label] = []

var multi_event_editor: MultiEventEditor:
	get: return get_parent().get_parent()

var event_owner: Node:
	get: return multi_event_editor.event_owner

@onready var pre_text := delete_button.text

var _has_setup_event := false

func _ready() -> void:
	if self == get_tree().edited_scene_root:
		return
	event = event
	branch_label.hide()
	
	inspect_button.pressed.connect(func ():
		inspect_event.emit(event)
	)
	delete_button.pressed.connect(func ():
		if pre_text == delete_button.text:
			delete_button.text = "Are you sure?"
			get_tree().create_timer(2.0).timeout.connect(func ():
				if is_instance_valid(self):
					delete_button.text = pre_text
			)
		else:
			request_delete.emit(event)
	)

func _process(delta: float) -> void:
	update_appearance()

func update_appearance():
	var changed := false
	if event:
		## Update node title.
		var target_title := event.to_string()
		if title != target_title:
			title = target_title
			changed = true
		
		## Update node color.
		var event_color := event.get_editor_color()
		get_theme_stylebox("titlebar").bg_color = event_color * 0.7
		get_theme_stylebox("titlebar_selected").bg_color = event_color * 0.85
		
		## Update node description.
		var description := event.get_editor_description_text(event_owner)
		if rich_text_label.text != description or not rich_text_label.visible:
			changed = true
			rich_text_label.text = description
			rich_text_label.visible = len(description) > 0
		
		# Setup connection ports.
		if event.has_connection_ports():
			## Enable default port.
			set_slot_enabled_left(0, true)
			set_slot_enabled_right(0, true)
			
			## Update node connections.
			var branch_names := event.get_branch_names().slice(1)
			
			## Add new branch labels.
			for i in range(branch_names.size() - branch_nodes.size()):
				var new_node := branch_label.duplicate()
				add_child(new_node)
				branch_nodes.append(new_node)
				new_node.visible = true
				
				var slot_idx := branch_nodes.size() + 2
				set_slot_enabled_left(slot_idx, false)
				set_slot_enabled_right(slot_idx, true)
				set_slot_type_right(slot_idx, 0)
				set_slot_color_right(slot_idx, Color.WHITE)
				changed = true
			
			## Remove unused branch labels.
			for i in range(branch_nodes.size() - branch_names.size()):
				var remove_node := branch_nodes.pop_back()
				remove_node.visible = false
				remove_node.queue_free()
				changed = true
			
			## Update branch label names.
			for i in branch_names.size():
				var name: String = branch_names[i]
				if branch_nodes[i].text != name:
					branch_nodes[i].text = name
		else:
			## Disable default port.
			set_slot_enabled_left(0, false)
			set_slot_enabled_right(0, false)
			
			## Clear all branch nodes.
			for branch_node in branch_nodes.duplicate():
				branch_node.visible = false
				branch_node.queue_free()
				changed = true
		
		## Now, call event process.
		if not _has_setup_event:
			event._editor_ready(event_owner, _info_container)
			_has_setup_event = true
		event._editor_process(event_owner, _info_container)
	else:
		if title != "None":
			title = "None"
			changed = true
		var event_color := Color.DIM_GRAY
		get_theme_stylebox("titlebar").bg_color = event_color
		get_theme_stylebox("titlebar_selected").bg_color = Color(0.3, 0.3, 0.3, 1.0) + event_color
		if rich_text_label.visible:
			rich_text_label.visible = false
			changed = true
		
	## Package the node.
	if changed:
		size = Vector2.ONE

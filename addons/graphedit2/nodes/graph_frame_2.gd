@tool
extends GraphFrame
class_name GraphFrame2

## The node resource associated with the GraphFrame.
## Must be a GraphFrameResource or otherwise implement its traits.
@export var resource: Resource:
	set(x):
		if not x or GraphFrameResource.validate_implementation(x):
			resource = x
			_update_appearance()

@onready var graph_edit: GraphEdit2 = get_parent()

var inspect_button: Button
var close_button: Button

func _ready() -> void:
	# Set header label to fill real quick
	#var title_bar := get_titlebar_hbox()
	#var header_label: Label = get_titlebar_hbox().get_child(0)
	#header_label.size_flags_horizontal = SIZE_FILL + SIZE_EXPAND
	
	inspect_button = _add_titlebar_button(1, "I")
	inspect_button.pressed.connect(func (): EditorInterface.edit_resource(resource))
	close_button = _add_titlebar_button(2, "X")
	close_button.pressed.connect(func (): graph_edit.remove_resource(resource))

## Adds a button to the titlebar.
func _add_titlebar_button(index: int, text: String = "", icon: Texture2D = null) -> Button:
	# Create button.
	var button := Button.new()
	button.text = text
	button.icon = icon
	
	# Add to titlebar.
	var title_bar := get_titlebar_hbox()
	button.custom_minimum_size = Vector2(title_bar.size.y, 0)
	title_bar.add_child(button)
	title_bar.move_child(button, index)
	return button

## Called to update the visual properties of our node.
func _update_appearance():
	if resource:
		## Setup node title.
		if title != resource.get_graph_frame_title():
			title = resource.get_graph_node_title()
			var style_box := GraphNode2._get_title_bar_stylebox()
			style_box.bg_color = resource.get_graph_frame_color() * 0.7
			var selected_style_box := GraphNode2._get_title_bar_stylebox()
			selected_style_box.bg_color = resource.get_graph_frame_color() * 0.85
			add_theme_stylebox_override(&"titlebar", style_box)
			add_theme_stylebox_override(&"titlebar_selected", selected_style_box)
	else:
		## Cleanup node title.
		title = ""
		remove_theme_stylebox_override(&"titlebar")
		remove_theme_stylebox_override(&"titlebar_selected")

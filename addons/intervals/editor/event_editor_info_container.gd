@tool
extends VBoxContainer
class_name EventEditorInfoContainer

@onready var event_node: EventNode = $".."
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var buttons: HBoxContainer = $Buttons
@onready var inspect: Button = $Buttons/Inspect
@onready var delete: Button = $Buttons/Delete

## Adds a new button to the Buttons row.
func add_new_button(text: String, index := -1) -> Button:
	var new_button := inspect.duplicate()
	new_button.name = text
	new_button.text = text
	buttons.add_child(new_button)
	buttons.move_child(new_button, index)
	return new_button

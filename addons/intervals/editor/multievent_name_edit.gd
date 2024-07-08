@tool
extends TextEdit

func _input(event):
	if Input.is_action_pressed("ui_text_newline") and has_focus():
		get_tree().set_input_as_handled()

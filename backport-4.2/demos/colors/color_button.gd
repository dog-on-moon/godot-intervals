@tool
extends Button

@export var color := Color.WHITE:
	set(x):
		color = x
		get_theme_stylebox("normal").bg_color = x

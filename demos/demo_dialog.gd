extends Demo

signal test

@onready var background: TextureRect = $Background

@export_enum("One", "Two", "Three") var asdf

func update_color(_color: Color, duration: float):
	LerpProperty.new(background, ^"self_modulate", duration, _color).as_tween(self)


@export var color: Color

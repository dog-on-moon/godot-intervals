extends Demo

@onready var background: TextureRect = $Background

func update_color(color: Color, duration: float):
	LerpProperty.new(background, ^"self_modulate", duration, color).as_tween(self)


@export var color: Color

@icon("res://addons/intervals/icons/interval.png")
extends Interval
class_name Wait
## An Interval delay.

@export var time: float

func _init(p_time := 0.0) -> void:
	time = p_time

func _onto_tween(tween: Tween):
	tween.tween_interval(time)

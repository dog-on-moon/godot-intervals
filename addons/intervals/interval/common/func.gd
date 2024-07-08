@icon("res://addons/intervals/icons/interval.png")
extends Interval
class_name Func
## An Interval function call.

var method: Callable

func _init(p_method: Callable) -> void:
	method = p_method

func onto_tween(tween: Tween):
	tween.tween_callback(method)

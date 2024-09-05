@icon("res://addons/intervals/icons/interval.png")
extends Interval
class_name Connect
## Dynamically connects a method to a signal.

var _signal: Signal
var method: Callable
var flags: int
var ignore_signal_args: bool

func _init(p_signal: Signal, p_method: Callable, p_flags := 0, p_ignore_signal_args := false) -> void:
	_signal = p_signal
	method = p_method
	flags = p_flags
	ignore_signal_args = p_ignore_signal_args

func _onto_tween(tween: Tween):
	tween.tween_callback(
		_signal.connect.bind(
			method if not ignore_signal_args else disable_call_args(method),
			flags
		)
	)

## Given a function, return a new callable which can always be called
## regardless of how many arguments are passed into it.
## TODO: https://github.com/godotengine/godot/pull/82808
static func disable_call_args(callable: Callable) -> Callable:
	return func (_1=null, _2=null, _3=null, _4=null, _5=null, _6=null, _7=null, _8=null, _9=null):
		callable.call()

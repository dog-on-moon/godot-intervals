@icon("res://addons/intervals/icons/interval_container.png")
extends Interval
class_name IntervalContainer
## Base class for interval containers.
## 
## Interval containers store and playback multiple Intervals.
## They can be used to arrange multiple Intervals together.

var intervals: Array[Interval]

func _init(p_intervals: Array[Interval] = []) -> void:
	intervals = p_intervals

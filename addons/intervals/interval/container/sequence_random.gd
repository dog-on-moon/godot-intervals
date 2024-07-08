@icon("res://addons/intervals/icons/interval_container.png")
extends IntervalContainer
class_name SequenceRandom
## An IntervalContainer that plays its contents in a random order.

func onto_tween(owner: Node, tween: Tween):
	var intervals_copy := intervals.duplicate()
	intervals_copy.shuffle()
	for ival in intervals_copy:
		ival.onto_tween(owner, tween)

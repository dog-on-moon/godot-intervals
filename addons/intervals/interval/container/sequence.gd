@icon("res://addons/intervals/icons/interval_container.png")
extends IntervalContainer
class_name Sequence
## An IntervalContainer that plays all of its elements ordered, one by one.

func onto_tween(tween: Tween):
	if not intervals:
		return
	intervals[0].onto_tween(tween)
	for ival in intervals.slice(1):
		tween.chain()
		ival.onto_tween(tween)

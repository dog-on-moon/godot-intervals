extends Node
class_name Demo

@export var event_player: EventPlayer

func _ready() -> void:
	if event_player:
		event_player.finished.connect(queue_free)

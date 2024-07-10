extends Node
class_name Demo

signal done()

@export var event_player: EventPlayer

func _ready() -> void:
	if event_player:
		done.connect(_on_done)
		event_player.finished.connect(done.emit)

func _on_done():
	if self == get_tree().current_scene:
		get_tree().quit()

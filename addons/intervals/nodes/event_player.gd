@icon("res://addons/intervals/icons/event_player.png")
extends Node
class_name EventPlayer
## A simple node for storing and playing back an Event.

signal finished

## The event to play back.
@export var multi_event: MultiEvent = null

## Determines if this event plays automatically when entering the scene.
@export var autoplay := false

## Determines if the event is looping.
@export var looping := false

## The state of the multi-event.
@export var state := {}

var tween: Tween
var active := false

var plays := 0

func _ready() -> void:
	if autoplay:
		play()

func _exit_tree() -> void:
	if tween:
		tween.kill()
		tween = null
	plays = 0
	state = {}

func play(callback: Callable = func(): pass):
	active = true
	plays += 1
	state['PLAYS'] = plays
	state['EventPlayer'] = self
	tween = multi_event.play(owner, _complete.bind(callback), state)

func _complete(callback: Callable):
	active = false
	tween = null
	if callback:
		callback.call()
	finished.emit()
	if looping:
		play.call_deferred(callback)

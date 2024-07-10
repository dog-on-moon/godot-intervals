@tool
extends Container
class_name DialogueContainer
## Preferabaly this would be created as an autoload,
## but for the purpose of the demo I'm keeping it
## contained in the scene to help visualize it.

const DIALOGUE_BOX = preload("res://demos/dialog/dialogue_box.tscn")

@export var padding := 4

## Emitted when we confirm finish a dialogue box.
signal dialogue_complete

static var singleton: DialogueContainer

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		singleton = self

## Adds a text string into the DialogueContainer.
func add_text(text: String):
	var dialogue_box := DIALOGUE_BOX.instantiate()
	add_child(dialogue_box)
	# move_child(dialogue_box, 0)
	
	dialogue_box.text = text
	dialogue_box.visible = true
	dialogue_box.on_confirm.connect(dialogue_complete.emit, CONNECT_ONE_SHOT)
	dialogue_box.start()

func clear_text():
	var move_ival := []
	var clear_ival := []
	for dialogue_box: DialogueBox in get_children():
		move_ival.append(
			LerpProperty.setup(
				dialogue_box, ^"position:x", 0.3, dialogue_box.size.x
			).values(null, true).interp(Tween.EASE_IN, Tween.TRANS_CUBIC)
		)
		clear_ival.append(Func.new(dialogue_box.queue_free))
	
	Sequence.new([
		# Move all dialogue boxes out of the way.
		Parallel.new(move_ival),
		# Delete all dialogue box nodes.
		Parallel.new(clear_ival)
	]).as_tween(self)

## Similar to VBoxContainer but without the resizing baggage
func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		var y := size.y
		var children := get_children()
		children.reverse()
		for c in children:
			y -= c.size.y + padding
			c.position.y = y

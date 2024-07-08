@tool
extends Event
class_name AnimationPlayerEvent

@export_node_path("AnimationPlayer") var animation_player_np: NodePath = ^""
@export var animation_name: StringName
@export var blocking := true

## Returns the interval for this specific event.
## Must be implemented by event subclasses.
#func _get_interval(owner: Node, state: Dictionary) -> Interval:
	#var animation_player: AnimationPlayer = owner.get_node(animation_player_np)
	#if blocking:
		#animation_player.animation_finished.connect(animation_finished, CONNECT_ONE_SHOT)
		#return Func.new(animation_player.play, [animation_name])
	#else:
		#return Sequence.new([
			#Func.new(animation_player.play, [animation_name]),
			#Func.new(done.emit)
		#])

func animation_finished(_name):
	done.emit()

#region Editor Overrides
## The color that represents this event in the editor.
static func get_editor_color() -> Color:
	return Color(0.765, 0.557, 0.945, 1.0)

## String representation of the event. Important to define.
static func get_editor_name() -> String:
	return "AnimationPlayerEvent"

## The editor description of the event.
func get_editor_description_text(owner: Node) -> String:
	var valid_np := animation_player_np and owner and owner.get_node_or_null(animation_player_np)
	return "[b]%s\nAnimation:[/b] %s\n%sBlocking" % [
		animation_player_np if valid_np else "[color=red]Invalid NodePath[/color]",
		animation_name if animation_name else "undefined", "Not " if not blocking else "Is "
	]

## The editor category that the event belongs to.
static func get_editor_category() -> String:
	return "Animation"
#endregion

@tool
extends Event
class_name AnimationPlayerEvent
## Plays an animation on an AnimationPlayer.

@export_node_path("AnimationPlayer") var animation_player_np: NodePath = ^""
@export var animation_name: StringName
@export var blocking := true

func _get_interval(_owner: Node, _state: Dictionary) -> Interval:
	var animation_player: AnimationPlayer = _owner.get_node(animation_player_np)
	if blocking:
		animation_player.animation_finished.connect(animation_finished, CONNECT_ONE_SHOT)
		return Func.new(animation_player.play.bind(animation_name))
	else:
		return Sequence.new([
			Func.new(animation_player.play.bind(animation_name)),
			Func.new(done.emit)
		])

func animation_finished(_name):
	done.emit()

static func get_editor_color() -> Color:
	return Color(0.765, 0.557, 0.945, 1.0)

static func get_editor_name() -> String:
	return "Play Animation"

func get_editor_description_text(_owner: Node) -> String:
	return "%s\n[b]Animation:[/b] %s\n%sBlocking" % [
		get_node_path_string(_owner, animation_player_np),
		animation_name if animation_name else "undefined", "Not " if not blocking else "Is "
	]

static func get_editor_category() -> String:
	return "Animation"

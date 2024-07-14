@icon("res://addons/graphedit2/icons/ResGraphFrame.png")
@tool
extends GraphElementResource
class_name GraphFrameResource
## A resource for information within a GraphFrame.
## huge TODO tbh

static func get_graph_args() -> Dictionary:
	return super().merged({})

func _make_graph_control() -> Control:
	return GraphFrame2.new()

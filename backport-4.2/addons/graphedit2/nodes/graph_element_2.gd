@tool
extends GraphElement
class_name GraphElement2

## The node resource associated with the GraphElement.
## Must be a GraphElementResource or otherwise implement its traits.
@export var resource: GraphElementResource:
	set(x):
		resource = x
		_has_called_resource_ready = false
		_update_appearance()

@onready var graph_edit: GraphEdit2 = get_parent()

var _has_called_resource_ready := false

func _process(delta: float) -> void:
	if resource:
		resource._editor_process(graph_edit, self)
	_update_appearance()

## Called to update the visual properties of our node.
func _update_appearance():
	## Setup resource calls here.
	if not _has_called_resource_ready:
		resource._editor_ready(graph_edit, self)
		_has_called_resource_ready = true
	resource._editor_process(graph_edit, self)

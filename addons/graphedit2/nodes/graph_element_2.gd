@tool
extends GraphElement
class_name GraphElement2

## The node resource associated with the GraphElement.
## Must be a GraphElementResource or otherwise implement its traits.
@export var resource: Resource:
	set(x):
		if not x or GraphElementResource.validate_implementation(x):
			if x and resource != x:
				x._editor_ready(graph_edit, self)
			_update_appearance()

@onready var graph_edit: GraphEdit2 = get_parent()

func _process(delta: float) -> void:
	if resource:
		resource._editor_process(graph_edit, self)
	_update_appearance()

## Called to update the visual properties of our node.
func _update_appearance():
	pass

@icon("res://addons/graphedit2/icons/ResGraphEdit.png")
@tool
extends Resource
class_name GraphEditResource
## A resource for storing information within a GraphEdit.

## Emitted to refresh the GraphEditor's visual state.
signal editor_refresh

# 4.2 backport: @export instead of @export_storage for resources, connections,
# and positions.

## The elements that the GraphEdit keeps track of.
@export var resources: Array = []

## Dictionary of stored event connections.
## A connection is [from_resource, from_port, to_resource, to_port]
@export var connections: Array = []

## Editor storage for resource positions.
## Dictionary[Resource, Vector2]
@export var positions := {}

## Adds a resource. Must be unique.
func add_resource(resource: GraphElementResource, position: Vector2 = Vector2.ZERO):
	assert(resource not in resources)
	resource._enter()
	resources.append(resource)
	positions[resource] = _validate_position(position)
	editor_refresh.emit()

## Removes a resource.
func remove_resource(resource: GraphElementResource):
	assert(resource in resources)
	resources.erase(resource)
	positions.erase(resource)
	for c in connections.duplicate():
		if resource == c[0] or resource == c[2]:
			connections.erase(c)
	editor_refresh.emit()

## Connects two resources together.
## (Resources are type GraphNodeResource)
func connect_resources(from_resource, from_port: int, to_resource, to_port: int):
	assert(from_resource in resources)
	assert(to_resource in resources)
	assert(from_resource.get_output_connections() >= from_port)
	assert(to_resource.get_input_connections() >= to_port)
	var connection: Array = [from_resource, from_port, to_resource, to_port]
	for c in connections:
		assert(c != connection)
	connections.append(connection)
	editor_refresh.emit()

## Disconnects two resources from eachother.
## (Resources are type GraphNodeResource)
func disconnect_resources(from_resource, from_port: int, to_resource, to_port: int):
	assert(from_resource in resources)
	assert(to_resource in resources)
	var connection = [from_resource, from_port, to_resource, to_port]
	for c in connections:
		if c == connection:
			connections.erase(c)
			editor_refresh.emit()
			return
	assert(false)

## Stores the XY position of the event node in the editor.
func move_resource(resource: GraphElementResource, position: Vector2):
	assert(resource in resources)
	if not positions[resource].is_equal_approx(position):
		positions[resource] = position
		editor_refresh.emit()

## Returns the resources connected to each input port.
## Input is type GraphNodeResource
## Returns Dictionary[int, Array[GraphNodeResource]]
func get_resource_inputs(resource) -> Dictionary:
	var inputs := {}
	for c in connections:
		if c[2] == resource:
			# 4.2 backport: Use backported get_or_add().
			#inputs.get_or_add(c[3], []).append(c[0])
			GraphEditResource._backport_get_or_add(inputs, c[3], []).append(c[0])
	return inputs

## Quick, non-optimal backport of dict.get_or_add() in Godot 4.3.
## Implemented in Godot 4.2.
static func _backport_get_or_add(dict: Dictionary, key: Variant, else_add: Variant) -> Variant:
	if !(key in dict):
		dict[key] = else_add
	return dict[key]

## Returns the resources connected to each output port.
## Input is type GraphNodeResource
## Returns Dictionary[int, Array[GraphNodeResource]]
func get_resource_outputs(resource) -> Dictionary:
	var outputs := {}
	for c in connections:
		if c[0] == resource:
			# 4.2 backport: Use backported get_or_add().
			#outputs.get_or_add(c[1], []).append(c[2])
			GraphEditResource._backport_get_or_add(outputs, c[1], []).append(c[2])
	return outputs

## Returns a list of all node resources missing an input connection.
## Returns Array[GraphNodeResource]
func get_unresolved_input_resources(include_no_input_nodes := false) -> Array:
	var ret_resources := {}
	
	## Collect initial resources.
	for resource in resources:
		if &"get_input_connections" in resources[0] and (resource.get_input_connections() or include_no_input_nodes):
			ret_resources[resource] = null
	
	## Review all connections.
	## Any resource that is connected as a to_resource has a resolved input.
	for c in connections:
		ret_resources.erase(c[2])
	
	## Return result.
	return ret_resources.keys()

## Returns a list of all node resources missing an output connection.
## Returns Array[GraphNodeResource]
func get_unresolved_output_resources(include_no_output_nodes := false) -> Array:
	var ret_resources := {}
	
	## Collect initial resources.
	for resource: GraphElementResource in resources:
		if &"get_output_connections" in resources[0] and (resource.get_output_connections() or include_no_output_nodes):
			ret_resources[resource] = null
	
	## Review all connections.
	## Any resource that is connected as a from_resource has a resolved output.
	for c in connections:
		ret_resources.erase(c[0])
	
	## Return result.
	return ret_resources.keys()

func _validate_position(pos: Vector2) -> Vector2:
	var pos_check := true
	while pos_check:
		pos_check = false
		for other_p in positions.values():
			if pos.is_equal_approx(other_p):
				pos += Vector2(32, 32)
				pos_check = true
				break
	return pos

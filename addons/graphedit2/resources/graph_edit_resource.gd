@icon("res://addons/graphedit2/icons/ResGraphEdit.png")
@tool
extends Resource
class_name GraphEditResource
## A resource for storing information within a GraphEdit.

## Emitted to refresh the GraphEditor's visual state.
signal editor_refresh

## A class to measure a connection between two resources.
## TODO - turn into a Struct in the future to optimize them
class Connection:
	var from_resource: Resource
	var from_port: int
	var to_resource: Resource
	var to_port: int
	
	func _init(p_from_resource: Resource, p_from_port: int, p_to_resource: Resource, p_to_port: int) -> void:
		from_resource = p_from_resource
		from_port = p_from_port
		to_resource = p_to_resource
		to_port = p_to_port
	
	func equals(other: Connection):
		return from_resource == other.from_resource \
			and from_port == other.from_port \
			and to_resource == other.to_resource \
			and to_port == other.to_port

## The elements that the GraphEdit keeps track of.
## These resources must implement GraphElementResource.
@export_storage var resources: Array[Resource] = []

## Dictionary of stored event connections.
@export_storage var connections: Array[Connection] = []

## Editor storage for resource positions.
## Dictionary[Resource, Vector2]
@export_storage var positions := {}

## Adds a resource. Must be unique.
func add_resource(resource: Resource, position: Vector2 = Vector2.ZERO):
	assert(resource not in resources)
	assert(GraphElementResource.validate_implementation(resource))
	resources.append(resource)
	positions[resource] = position
	editor_refresh.emit()

## Removes a resource.
func remove_resource(resource: Resource):
	assert(resource in resources)
	resources.erase(resource)
	positions.erase(resource)
	for c: Connection in connections.duplicate():
		if resource == c.from_resource or resource == c.to_resource:
			connections.erase(c)
	editor_refresh.emit()

## Connects two resources together.
func connect_resources(from_resource: Resource, from_port: int, to_resource: Resource, to_port: int):
	assert(from_resource in resources)
	assert(to_resource in resources)
	assert(from_resource.get_outbound_connections() >= from_port)
	assert(to_resource.get_inbound_connections() >= to_port)
	var connection := Connection.new(from_resource, from_port, to_resource, to_port)
	for c: Connection in connections:
		assert(not c.equals(connection))
	connections.append(connection)
	editor_refresh.emit()

## Disconnects two resources from eachother.
func disconnect_resources(from_resource: Resource, from_port: int, to_resource: Resource, to_port: int):
	assert(from_resource in resources)
	assert(to_resource in resources)
	var connection := Connection.new(from_resource, from_port, to_resource, to_port)
	for c: Connection in connections:
		if c.equals(connection):
			connections.erase(c)
			editor_refresh.emit()
			return
	assert(false)

## Stores the XY position of the event node in the editor.
func move_resource(resource: Resource, position: Vector2):
	assert(resource in resources)
	if not positions[resource].is_equal_approx(position):
		positions[resource] = position
		editor_refresh.emit()

## Returns True if a given resource has correctly implemented our trait.
static func validate_implementation(resource: Resource) -> bool:
	return resource is GraphEditResource or (resource \
		and resource.has_method(&"add_resource") \
		and resource.has_method(&"remove_resource") \
		and resource.has_method(&"connect_resource") \
		and resource.has_method(&"disconnect_resource") \
		and resource.has_method(&"move_resource"))

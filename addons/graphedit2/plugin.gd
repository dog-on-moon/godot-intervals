@tool
extends EditorPlugin
class_name GraphEdit2Plugin
## GraphEdit2 - GraphEdit classes designed for editor plugin usage
## By Mica
## Icons from GodotEngine

static var undo_redo: EditorUndoRedoManager

func _enter_tree():
	undo_redo = get_undo_redo()
	
	add_custom_type("GraphEditResource", 	"Resource", preload("res://addons/graphedit2/resources/graph_edit_resource.gd"), preload("res://addons/graphedit2/icons/ResGraphEdit.png"))
	add_custom_type("GraphElementResource", "Resource", preload("res://addons/graphedit2/resources/graph_element_resource.gd"), preload("res://addons/graphedit2/icons/ResGraphElement.png"))
	add_custom_type("GraphFrameResource", 	"GraphElementResource", preload("res://addons/graphedit2/resources/graph_frame_resource.gd"), preload("res://addons/graphedit2/icons/ResGraphFrame.png"))
	add_custom_type("GraphNodeResource", 	"GraphElementResource", preload("res://addons/graphedit2/resources/graph_node_resource.gd"), preload("res://addons/graphedit2/icons/ResGraphNode.png"))
	
	add_custom_type("GraphElement2", "GraphElement", preload("res://addons/graphedit2/nodes/graph_element_2.gd"), preload("res://addons/graphedit2/icons/GraphElement.png"))
	add_custom_type("GraphFrame2", "GraphFrame", preload("res://addons/graphedit2/nodes/graph_frame_2.gd"), preload("res://addons/graphedit2/icons/GraphFrame.png"))
	add_custom_type("GraphNode2", "GraphNode", preload("res://addons/graphedit2/nodes/graph_node_2.gd"), preload("res://addons/graphedit2/icons/GraphNode.png"))
	add_custom_type("GraphEdit2PopupMenu", "PopupMenu", preload("res://addons/graphedit2/nodes/graph_edit_2_popup_menu.gd"), preload("res://addons/graphedit2/icons/PopupMenu.png"))
	add_custom_type("GraphEdit2", "GraphEdit", preload("res://addons/graphedit2/nodes/graph_edit_2.gd"), preload("res://addons/graphedit2/icons/GraphEdit.png"))

func _exit_tree():
	remove_custom_type("GraphEdit2")
	remove_custom_type("GraphEdit2PopupMenu")
	remove_custom_type("GraphNode2")
	remove_custom_type("GraphFrame2")
	remove_custom_type("GraphElement2")
	
	remove_custom_type("GraphNodeResource")
	remove_custom_type("GraphFrameResource")
	remove_custom_type("GraphElementResource")
	remove_custom_type("GraphEditResource")
	
	undo_redo = null

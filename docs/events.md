# Events

Events are a Resource which represent a blocking function call. These functions can be tied to any GDScript action in your project: function calls, property updates, custom user-defined actions, and more. Events can branch out and connect to other Events, supporting parallel Event playback or branching routes. Events are orchestrated within a MultiEvent using a custom GraphEdit editor.

The playback for these function calls are modelled using Intervals for ease of creating complex custom Events.

## Base Event Class

The Event class consists of a few distinct components: the interval, branching logic, and various editor node overrides.

### Interval

The main logic of the Event is implemented in `Event._get_interval`. This function returns an Interval that is played back at runtime. This Interval must eventually emit `done.emit` (either within the Interval or deferred within some function) to prevent deadlocks.

This function receives two arguments:
- `owner: Node`
  - This is the root node of the current scene (the value of `Node.owner` from each Node in the scene).
  - Any NodePath exports for Event resources are based on the path of this owner.
- `state: Dictionary`
  - The state dictionary is passed in from an EventPlayer and is distributed to every Event played back within a MultiEvent.
  - This can be used for all kinds of dependency injection -- if you have important external information (like Nodes in a scene, or dialogue information), you can pass it through the state dictionary.
  - There are also some built-in Events to manipulate the state dictionary and route based on defined state.

### Branching Logic

Each Event has multiple output nodes that may connect to other events. The number of output branches is defined by how many elements are in the return value of `Event.get_branch_names`, which also determines the names of these branches on the node. (The 0th element is rendered with no text by default.)

Immediately after `Event.done` is emitted, the MultiEvent checks the return value of its `Event.get_branch_index`. This function chooses exactly one output branch that is used for the Event (basically indexing into the branch name array) and performs each Event connected to it. Note that if there are no connected events on the selected branch, the MultiEvent will check the default branch (the 0th index). If there are no connected events found whatsoever, the Event terminates.

In most cases, both `Event.get_branch_names` and `Event.get_branch_index` do not need to be overridden.

### Editor Node Overrides

There are many custom functions provided by the `GraphNodeResource` and `GraphElementResource` classes (which Event inherits from) that provide information for how to render the Event's Control node in the MultiEvent editor. Not all are necessary to override, but some common ones are detailed here:

- `get_graph_dropdown_category`
  - Returns the category that the Event belongs to when creating a new Event.
  - This category can include /s to dedicate subfolders within Event categories.
- `get_graph_node_title`
  - Returns the title of the Event node, shown in both the dropdown creation menu and on the Node header itself.
- `get_graph_node_description`
  - Returns a String that is used in a RichTextLabel for the GraphNode.
  - You can obtain the edited scene root via `Event.get_editor_owner`.
    - This owner is the same owner used in `Event._get_interval`.
    - This function can also be used for `_editor_ready` and `_editor_process`.
  - The logic for this is text label is implemented in `GraphNodeElement`.
- `get_graph_node_color`
  - Returns the modulate associated with this node.
    - It ends up being slightly darker on the GraphNode header to help the white header text's visibility'.
- `_editor_ready`
  - Called as an injected _ready function for this Event's GraphNode in the editor.
  - This can be used to do custom UI work for this Event's GraphNode.
  - Note that the true types of the function are `(_edit: GraphEdit2, _element: GraphNode2)`, just reduced to the base classes to circumvent covariance issues.
- `_editor_process`
  - Called on the Editor's process frame for this Event's GraphNode in the editor.
  - See above for the function's true types.
- `_editor_flatten_default_label`
  - By default, the base Event's editor ready/process functions will flatten the initial branch label, since it looks a little nicer. (It's a bit hacky :P)
  - You can override this function to return false to 

These ones are undefined in Event, but are still worth knowing about:
- `is_in_graph_dropdown`
  - Determines if this Event can be created in the editor's dropdown menu. The Event will still exist in the Editor, this just determines if new ones can be created.
- `graph_can_be_copied`
  - Determines if this Event can be copied and pasted within the Editor.

## Custom Events

To create a custom Event, simply extend Event. **Ensure that it is a @tool script and has a defined class_name, or it will not register properly.**

You'll need to override get_interval and most parts of the editor node overrides. You shouldn't need to address the branching logic unless you're creating some kind of custom router.

There are a few default Events that you can look at for simple reference (EmitEvent, WaitEvent, PrintEvent are good examples). There are some more complex ones that use the system to its full advantage as well (RouterSignalMulti, PropertyEvent).

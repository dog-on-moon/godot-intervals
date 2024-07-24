# GraphEdit2 

GraphEdit2 is a supplementary addon to the development of Intervals and potentially other GraphEdit-based tools in Godot.

In its current state, GraphEdit (the main Control node that the Event Editor uses) has two issues:
1. It is experimental. Its implementation is subject to change at any time.
2. The interface puts a lot of the implementation burden on the developer (most things, like creating/maintaining node connections, must be managed by scripting on top of it).

To help address both of these issues, I created GraphEdit2 as a middle-man for utilizing GraphEdit. It implements consistent logic for GraphEdit while allowing graph connections and such to be implemented in custom resources. This means that the Event addon does not have to reimplement or include any GraphEdit logic by itself, and should the GraphEdit API updates in the future, only GraphEdit2 will need to be adjusted to keep the library functional.

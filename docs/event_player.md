# EventPlayer

The EventPlayer is a Node designed with parity to the AnimationPlayer. It supports the playback of a MultiEvent, a resource which contains a graph of multiple Events. You can begin an EventPlayer by calling `EventPlayer.play()`, which supports an optional callback function.

## Attributes

The attributes of the EventPlayer are listed below.

- `signal finished`
  - Emitted when the EventPlayer's internal Event is complete.
- `var multi_event: MultiEvent`
  - The MultiEvent data that this EventPlayer manages.
- `var autoplay: bool`
  - Determines if this EventPlayer plays automatically when entering the scene.
- `var looping: bool`
  - Determines if this EventPlayer will loop the Event after it is completed. Call is deferred.
- `var state: Dictionary`
  - A dictionary which can contain anything (functionally dependency injection).
  - Passed to the `_get_interval` function of all Events.
  - Has the following default arguments:
    - `'PLAYS'`: The number of times the EventPlayer has played.
    - `'EventPlayer'`: A reference to the EventPlayer node.
- `var tween: Tween`
  - The Tween that is managing the entire MultiEvent playback.
- `var active: bool`
  - Is true when the EventPlayer is running.
- `var plays: int`
  - Determines how many times this EventPlayer has ran in the scene.

## Notes

Technically, the EventPlayer layer is optional. If you want, you could perform any MultiEvent by calling its `play` function, or even performing any Event by calling its `_get_interval` function and converting the interval into a Tween. The usage of Events in this regard is not recommended.

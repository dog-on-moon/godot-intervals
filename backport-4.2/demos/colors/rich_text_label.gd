extends RichTextLabel

signal done

const SECONDS_PER_CHAR := 0.05

var _text_tween: Tween

@export_multiline var text_string := "":
	set(x):
		text_string = x
		text = x
		visible_characters = 0
		if _text_tween:
			_text_tween.kill()
		var char_count := get_total_character_count()
		_text_tween = Sequence.new([
			LerpProperty.new(self, ^"visible_characters", SECONDS_PER_CHAR * char_count, char_count),
			Wait.new(2.0),
			Func.new(func(): done.emit())
		]).as_tween(self)

class_name FadingColorRect
extends ColorRect

signal fade_in_completed
signal fade_out_completed

func _ready() -> void:
	fade_out()
	
func fade_in():
	visible = true
	modulate = Color.TRANSPARENT
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1.00)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "visible", false, 0.0)
	tween.tween_callback(fade_in_completed.emit)
	
func fade_out():
	visible = true
	modulate = Color.WHITE
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.00)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "visible", false, 0.0)
	tween.tween_callback(fade_out_completed.emit)

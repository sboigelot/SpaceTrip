class_name FadingColorRect
extends ColorRect

signal fade_in_completed
signal fade_out_completed

@export var visible_on_reeady:bool = false
@export var fade_out_on_ready:bool = false

func _ready() -> void:
	if not visible_on_reeady:
		visible = false
		modulate = Color.TRANSPARENT
	elif fade_out_on_ready:
		fade_out()
	
func fade_in(from_transparent: bool = true):
	visible = true
	if from_transparent:
		modulate = Color.TRANSPARENT
	elif modulate == Color.WHITE:
		await get_tree().process_frame
		fade_in_completed.emit()
		return
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_callback(fade_in_completed.emit)
	
func fade_out(from_white: bool = true):
	visible = true
	if from_white:
		modulate = Color.WHITE
	elif modulate == Color.TRANSPARENT:
		visible = false
		await get_tree().process_frame
		fade_out_completed.emit()
		return
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "visible", false, 0.0)
	tween.tween_callback(fade_out_completed.emit)

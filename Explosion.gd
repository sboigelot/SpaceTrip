class_name Explosion
extends ColorRect

@onready var start_scale: Vector2 = scale
@export var explode_time: float = 0.3

var _queue:int = 0
@export var queue: int:
	get():
		return _queue
	set(value):
		_queue = value
		if _queue > 0:
			start_explode_tween()

@export var min_delay: float = 0.25

func _ready() -> void:
	start_explode_tween()

func start_explode_tween():
	if _queue == 0:
		visible = false
		return
	
	visible = true
	_queue -= 1
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", start_scale, explode_time)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, explode_time)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	tween.tween_interval(min_delay)
	tween.tween_callback(start_explode_tween)

extends AnimationPlayer

class_name AutoStartAnimationPlayer

@export var auto_start_animation: String
@export var random_start: bool = true

func _ready() -> void:
	if auto_start_animation != "":
		play(auto_start_animation)
		if random_start:
			var current_animation = get_animation(auto_start_animation)
			seek(randf_range(0.0, current_animation.length))

class_name SynchronizedChildrenScale
extends Node2D

@export var children_scale_factor: float = 1.0

@export var children_scale: Vector2:
	get():
		if get_child_count(false) == 0:
			return Vector2.ONE
		return get_child(0).scale / children_scale_factor
	set(value):
		for child in get_children():
			child.scale = value * children_scale_factor

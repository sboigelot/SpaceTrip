class_name ShipModule
extends Node2D

var ship:Ship

func _ready() -> void:
	ship = get_parent() as Ship

func _process(delta: float) -> void:
	update_stats(delta)
	update_ui()

func update_stats(delta: float) -> void:
	pass
	
func update_ui():
	pass

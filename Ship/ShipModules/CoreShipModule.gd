class_name CoreShipModule
extends ShipModule

@export_group("UI elements")
@export var ui_distance_label: Label
@export var ui_speed_label: Label

var test_starting_distance := Big.new(100.0)
@onready var distance_travelled := Big.ZERO().plusEquals(test_starting_distance).setSuffixSeparatorOverride(" ")
var speed := Big.ZERO().setSuffixSeparatorOverride(" ")

func update_stats(delta: float) -> void:
	super.update_stats(delta)
	distance_travelled.plusEquals(speed.times(delta))

func update_ui():
	super.update_ui()
	ui_distance_label.text = "Distance: %sm" % distance_travelled.toMetricSymbol(false)
	ui_speed_label.text = "Speed: %sm/s" % speed.toMetricSymbol(false)

class_name CoreShipModule
extends ShipModule

@export_group("UI elements")
@export var ui_distance_label: Label
@export var ui_speed_label: Label

#@export_group("Module Properties")

var distance_travelled := Big.ZERO().setSuffixSeparatorOverride(" ")
var speed := Big.ZERO().setSuffixSeparatorOverride(" ")

func update_stats(delta: float) -> void:
	super.update_stats(delta)
	distance_travelled.plusEquals(speed.multiplyBy(delta))

func update_ui():
	super.update_ui()
	ui_distance_label.text = "Dist: %sm" % distance_travelled.toMetricSymbol(false)
	ui_speed_label.text = "Speed: %sm/s" % speed.toMetricSymbol(false)

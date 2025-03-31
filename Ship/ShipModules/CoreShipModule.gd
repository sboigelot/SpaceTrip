class_name CoreShipModule
extends ShipModule

@export_group("UI elements")
@export var ui_distance_label: Label
@export var ui_speed_label: Label

var test_starting_distance := Big.new(100.0)
@onready var distance_travelled := Big.ZERO().plusEquals(test_starting_distance).setSuffixSeparatorOverride(" ")
var speed := Big.ZERO().setSuffixSeparatorOverride(" ")

var _dimension_index: int = 0
var dimension_index: int:
	get():
		return _dimension_index
	set(value):
		_dimension_index = value
		update_background()
@export var dimension_backgrounds: Array[ColorRect]
@export var dimension_transition_overlay: ColorRect

func _ready() -> void:
	update_background()
	
func _process(delta: float) -> void:
	super._process(delta)
	
	if Input.is_action_just_pressed("ui_accept"):
		dimension_index += 1

func update_background():
	var start_transition = false
	
	var current_dimension: ColorRect
	var next_dimension: ColorRect
	
	for i in dimension_backgrounds.size():
		if dimension_backgrounds[i].visible:
			current_dimension = dimension_backgrounds[i]
			
		var is_next_dimension = i == dimension_index
		if is_next_dimension:
			next_dimension = dimension_backgrounds[i]
			if current_dimension == null:
				current_dimension = next_dimension
				current_dimension.visible = true
			start_transition =  current_dimension != next_dimension
	
	if start_transition:
		start_dimension_transition(current_dimension, next_dimension)
	else:
		dimension_transition_overlay.visible = false
		
func start_dimension_transition(current_dimension: ColorRect, next_dimension:ColorRect):
	dimension_transition_overlay.visible = true
	dimension_transition_overlay.modulate = Color.TRANSPARENT
	current_dimension.visible = true
	current_dimension.modulate = Color.WHITE
	next_dimension.visible = false
	next_dimension.modulate = Color.TRANSPARENT
	var tween = create_tween()
	tween.tween_property(dimension_transition_overlay, "modulate", Color.WHITE, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(current_dimension, "modulate", Color.TRANSPARENT, 0.75)
	tween.tween_property(current_dimension, "visible", false, 0.0)
	tween.tween_property(next_dimension, "visible", true, 0.0)
	tween.tween_property(next_dimension, "modulate", Color.WHITE, 0.75)
	tween.tween_property(dimension_transition_overlay, "modulate", Color.TRANSPARENT, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(dimension_transition_overlay, "visible", false, 0.0)

func update_stats(delta: float) -> void:
	super.update_stats(delta)
	distance_travelled.plusEquals(speed.times(delta))

func update_ui():
	super.update_ui()
	ui_distance_label.text = "Distance: %sm" % distance_travelled.toMetricSymbol(false)
	ui_speed_label.text = "Speed: %sm/s" % speed.toMetricSymbol(false)

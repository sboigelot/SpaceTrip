class_name RichTextTooltip
extends Node2D

@export var ui_tooltip_container: Container
@export var ui_tooltip_rich_text_label: RichTextLabel
@export var offset: Vector2 = Vector2(5.0, 5.0)

func _ready() -> void:
	close()

func close():
	ui_tooltip_rich_text_label.text = ""
	ui_tooltip_container.size = Vector2.ZERO
	visible = false

func open_and_move(content: String, anchor: Vector2, left_anchored:bool = false):
	ui_tooltip_rich_text_label.text = content
	ui_tooltip_container.size = Vector2.ZERO
	
	var tooltip_anchor = anchor
	if not left_anchored:
		tooltip_anchor += offset
	else:
		tooltip_anchor -= offset
		tooltip_anchor.x -= ui_tooltip_container.size.x
		
	ui_tooltip_container.position = tooltip_anchor
	visible = true
	await get_tree().process_frame
	ui_tooltip_container.size = Vector2.ZERO
	

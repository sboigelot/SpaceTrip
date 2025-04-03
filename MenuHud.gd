class_name MenuHUD
extends MarginContainer

@export var ship: Ship

@export_group("Visual Nodes")
@export var menu_occluder: FadingColorRect
@export var overall_occluder: FadingColorRect
@export var fullscreen_check_box: CheckBox
@export var audio_h_slider: HSlider
@export var default_container: Container
@export var confirm_container: Container
@export var game_hud: Container
@export var continue_button_container: Container

var on_open_game_hud_visibility: bool

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	fullscreen_check_box.set_pressed_no_signal(is_fullscreen())
	AudioServer.set_bus_volume_linear(0, 0.5)
	var audio_volume = AudioServer.get_bus_volume_linear(0)
	audio_h_slider.set_value_no_signal(audio_volume)
	
	if SaveHelper.savegame_exist():
		SaveHelper.load_game(ship)
		continue_button_container.visible = true
	else:
		continue_button_container.visible = false
	#continue_button_container.visible = SaveHelper.savegame_exist()
	open(false)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle()
		
	if Input.is_action_just_pressed("ui_accept"):
		if Engine.time_scale == 1:
			Engine.time_scale = 10
		else:
			Engine.time_scale = 1

func toggle():
	if visible:
		close()
	else:
		open()

func open(pause_game:bool = true):
	if pause_game:
		get_tree().paused = true
		menu_occluder.fade_in(false)
		continue_button_container.visible = true
	
	on_open_game_hud_visibility = game_hud.visible
	game_hud.visible = false
	
	visible = true
	default_container.visible = true
	confirm_container.visible = false
	
func close():
	get_tree().paused = false
	menu_occluder.fade_out(false)
	game_hud.visible = on_open_game_hud_visibility
	visible = false

func _on_save_button_pressed() -> void:
	SaveHelper.save_game(ship)
	close()
	
func _on_load_button_pressed() -> void:
	SaveHelper.load_game(ship)
	close()

func _on_restart_button_pressed() -> void:
	if SaveHelper.savegame_exist():
		default_container.visible = false
		confirm_container.visible = true
	else:
		close()
		ship.play_intro()
	
func _on_confirm_new_game_button_pressed() -> void:
	Engine.time_scale = 1.0
	SaveHelper.delete_savegame()
	overall_occluder.fade_out()
	await overall_occluder.fade_out_completed
	get_tree().reload_current_scene()

func _on_cancel_new_gamebutton_pressed() -> void:
	default_container.visible = true
	confirm_container.visible = false
	
func _on_quit_button_pressed() -> void:
	SaveHelper.save_game(ship)
	
	if OS.get_name() in ["Web", "HTML5"]:
		exit_fullscreen_mode()
	else:
		get_tree().quit()

func _on_continue_button_pressed() -> void:
	ship.skip_intro()
	close()

func _on_menu_button_pressed() -> void:
	toggle()

func _on_fullscreen_check_box_toggled(toggled_on: bool) -> void:
	toggle_fullscreen_mode()

func _on_audio_h_slider_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return
		
	var value = audio_h_slider.value
	AudioServer.set_bus_volume_linear(0, value)

func is_fullscreen() -> bool:
	var current_mode = DisplayServer.window_get_mode()
	var fullscreen = current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN
	return fullscreen

func exit_fullscreen_mode():
	var current_mode = DisplayServer.window_get_mode()
	if current_mode != DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
func toggle_fullscreen_mode():
	if is_fullscreen():
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)	

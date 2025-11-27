extends CanvasLayer

## Store App and PageController refs
var _app : Node
var _page_controller : Node

## NeonPageController Integration
func _ready() -> void:
	if not ProjectSettings.has_setting("autoload/App"):
		return
	
	await get_tree().process_frame
	
	_app = get_tree().root.get_node("App")
	_page_controller = _app._page_controller
	if _page_controller:
		if _app._runner._current_scene_name == "ExampleMainMenu":
			self.visible = false
		else:
			$MainMenuButton.visible = false

## Change between Example Scenes using the _change_scene function
func _on_change_scene_button_down(_example_scene_index: int) -> void:
	if ProjectSettings.has_setting("autoload/App"):
		_app._runner._change_scene("ExampleScene" + str((_example_scene_index)))
		
		if _page_controller:
			await _app._runner._scene_initialized
			_page_controller._turn_page_on(2)

	else:
		_no_plugin_message()

## Change to the Example Main Menu Scene, no loading screen example
func _on_main_menu_button_down() -> void:
	if ProjectSettings.has_setting("autoload/App"):
		## NeonPageController Integration
		if _page_controller:
			_page_controller._turn_page_off(_page_controller._current_page, 1)
		
		_app._runner._change_scene("ExampleMainMenu", false)
	else:
		_no_plugin_message()

func _no_plugin_message():
	print("[NeonSceneRunner Addon] The button you pressed did nothing, because the NeonSceneRunner Addon is disabled. If you wish to use it, please enable it in Project Settings > Plugins > NeonSceneRunner.")

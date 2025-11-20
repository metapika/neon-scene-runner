extends CanvasLayer

## Change between Example Scenes using the _change_scene function
func _on_change_scene_button_down(_example_scene_index: int) -> void:
	if ProjectSettings.has_setting("autoload/App"):
		get_tree().root.get_node("App")._runner._change_scene("ExampleScene" + str((_example_scene_index)))
	else:
		_no_plugin_message()

## Change to the Example Main Menu Scene, no loading screen example
func _on_main_menu_button_down() -> void:
	if ProjectSettings.has_setting("autoload/App"):
		get_tree().root.get_node("App")._runner._change_scene("ExampleMainMenu", false)
	else:
		_no_plugin_message()

func _no_plugin_message():
	print("[NeonSceneRunner Addon] The button you pressed did nothing, because the NeonSceneRunner Addon is disabled. If you wish to use it, please enable it in Project Settings > Plugins > NeonSceneRunner.")

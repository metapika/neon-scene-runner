extends CanvasLayer

## Change between Example Scenes using the _change_scene function
func _on_change_scene_button_down(_example_scene_index: int) -> void:
	App._runner._change_scene("ExampleScene" + str((_example_scene_index)))

## Change to the Example Main Menu Scene, no loading screen example
func _on_main_menu_button_down() -> void:
	App._runner._change_scene("ExampleMainMenu", false)

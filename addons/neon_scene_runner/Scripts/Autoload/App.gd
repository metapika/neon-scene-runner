extends Node

var _scene_holder

## NeonSceneRunner Core Script
var _runner : Control = null

## NeonPageController Core Script
var _page_controller : Control = null

## NeonGameModes Core Script
var _game_mode_manager : Control = null

## Runner initialization
func _ready() -> void:
	## Checking which scene Godot wants to load first
	var _target_scene = get_tree().current_scene
	var _target_is_runner = false
	
	## Detect if the user pressed F6 on a GameScene, or on the Runner Scene
	if _target_scene.name == "Runner":
		## User pressed F6 on the Runner Scene
		_target_is_runner = true
		_runner = _target_scene
		
		## Falling back to the Main Scene selected in Project Settings
		var _main_scene_path = ProjectSettings.get_setting("application/run/main_scene")
		var _main_scene = load(_main_scene_path).instantiate()
		add_child(_main_scene)
		_target_scene = _main_scene
	
	if !_target_is_runner:
		if not ResourceLoader.exists("res://addons/neon_scene_runner/Scenes/Runner.tscn", "PackedScene"):
			assert(false, "[NeonSceneRunner Addon Error] The Runner Scene file could not be loaded. Is the Runner Scene correctly named and placed in the /Scenes/Autoload folder?")
			
		_runner = load("res://addons/neon_scene_runner/Scenes/Runner.tscn").instantiate()
		add_child(_runner)
		await get_tree().process_frame
	
	## TODO: NeonGameModes integration
	#GlobalContainer.gamemode_manager._change_game_mode(0 if target_scene.name == "MainMenuScene" else 1)
	
	## Grab the reference for the scene holder for later use
	_scene_holder = _runner.get_node("CanvasLayer/SubViewportContainer/MainViewport")
	
	## Load the GameScenes at selected path
	_runner._find_all_game_scenes()
	
	## Finally add the selected scene to the MainViewPort and make SceneManager recognize it
	_target_scene.reparent(_scene_holder)
	_runner._find_init_scene(_target_scene)

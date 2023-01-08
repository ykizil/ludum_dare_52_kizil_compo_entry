extends Node

var game_difficulty = 1.0
var player : Object
var kamera : Object

var win_screen = preload("res://scenes/VictoryScreen.tscn")

var win_condition = 90
var player_dead = false
var playing = false

func _ready():
	pass

func _process(delta):
	if !playing:
		return
	game_difficulty += delta*(1.0/60.0)
	if int(game_difficulty*60) - 60 >= win_condition + 1:
		win_game()
		game_difficulty = 1.0
	#print(game_difficulty)

func start_game():
	playing = true
	game_difficulty = 1.0
	GameAudio.call_deferred("set_db_ingame",0)
	#yield(get_tree().create_timer(.5), "timeout")
	get_tree().change_scene("res://scenes/Main.tscn")
	#GameAudio.play_ingame()

func end_game():
	playing = false
	game_difficulty = 1.0
	GameAudio.call_deferred("set_db_menu",0)
	#yield(get_tree().create_timer(.5), "timeout")
	get_tree().change_scene("res://scenes/Menu.tscn")
	#GameAudio.play_menu()

func win_game():
	playing = false
	game_difficulty = 1.0
	if player_dead:
		return
	GameAudio.set_db_menu(-80)
	get_tree().change_scene_to(win_screen)

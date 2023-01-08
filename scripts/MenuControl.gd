extends Control

func _ready():
	GameAudio.play_menu()

func _on_QUIT_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_PLAY_pressed():
	GlobalUtility.start_game()
	GameAudio.play_ingame()
	pass # Replace with function body.

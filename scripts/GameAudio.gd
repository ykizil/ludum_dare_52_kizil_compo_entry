extends Node2D

var menu_desired_dB = -80
var ingame_desired_dB = -80

func _ready():
	$MuzikMenu.play()

func _process(delta):
	$MuzikIngame.volume_db += (ingame_desired_dB - $MuzikIngame.volume_db)/30
	$MuzikMenu.volume_db += (menu_desired_dB - $MuzikMenu.volume_db)/30

func play_menu():
	$MuzikMenu.play()
	menu_desired_dB = 0

func set_db_menu(db):
	silence_all()
	menu_desired_dB = db
	

func play_ingame():
	$MuzikIngame.play()
	ingame_desired_dB = 0
	
	
func set_db_ingame(db):
	silence_all()
	ingame_desired_dB = db

func play_win():
	$MuzikWin.play()

func set_db_win(db):
	silence_all()

func player_death():
	pass

func silence_all():
	ingame_desired_dB = -80
	menu_desired_dB = -80

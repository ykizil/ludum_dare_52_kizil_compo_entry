extends CanvasLayer

onready var score_label = $Control/Score
onready var death_ui = $Control/DeathStuff
onready var death_score = $Control/DeathStuff/DeathScore

func _ready():
	pass

func _process(delta):
	if GlobalUtility.player.current_state == GlobalUtility.player.states.DEAD or GlobalUtility.player.current_state == GlobalUtility.player.states.HARVESTED:
		death_ui.visible = true
		GameAudio.set_db_ingame(-80)
		return
	score_label.text = str(int(GlobalUtility.game_difficulty*60) - 60)
	death_score.text = "If only you could survive... \n ..." + str(GlobalUtility.win_condition + 60 - int(GlobalUtility.game_difficulty*60)) + " second(s) longer."
	death_ui.visible = false
	
	if int(GlobalUtility.game_difficulty*60) - 60 >= GlobalUtility.win_condition:
		$Fade.modulate.a += (1 - $Fade.modulate.a)/8

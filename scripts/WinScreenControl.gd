extends Control


func _ready():
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta):
	if Input.is_action_just_pressed("go_menu"):
		get_tree().change_scene("res://scenes/Menu.tscn")

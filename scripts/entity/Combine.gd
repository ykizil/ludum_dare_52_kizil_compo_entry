extends Area2D

const ent_type = "combine"

var to_left = false

onready var sprite = $Sprite
var tex_blood = preload("res://sprites/karakter/BicerDover_kan.png")

var speed = 200.0

var death_timer = 20

func _ready():
	pass

func _process(delta):
	move_forward(delta)
	count_death_timer(delta)

#GENERAL FUNCTIONS
func move_forward(delta): #move based on defined movement direction
	if to_left:
		position.x -= speed*delta
		sprite.flip_h = true
		$Hasat.position.x = 46
		$Hasat.scale.x = -1
	else:
		position.x += speed*delta
	if is_instance_valid(GlobalUtility.player):
		GlobalUtility.kamera.camera_shake(120/( 1 + 5*(GlobalUtility.player.global_position - self.global_position).length())  )

func to_left_util():
	sprite.flip_h = true

func count_death_timer(delta):
	death_timer -= delta
	if death_timer <= 0:
		queue_free()

func draw_blood():
	sprite.texture = tex_blood
	$Hasat.process_material.color = Color(1,0,0,1)
	$Hasat.process_material.scale = 10
	$harvest_death.play()
	GlobalUtility.kamera.camera_shake(20)

#SIGNAL FUNCTIONS
func _on_Combine_area_entered(area): #harvest areas
	if area.has_method("get_harvested"):
		area.get_harvested()
		if area.get("ent_type") == "player" or area.get("ent_type") == "enemy":
			draw_blood()

func _on_Combine_body_entered(body):
	if body.has_method("get_harvested"): #harvest bodies
		body.get_harvested()
		if body.get("ent_type") == "player" or  body.get("ent_type") == "enemy":
			draw_blood()

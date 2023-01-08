extends Area2D

#GLOBAL UTILITIDE SORUN CIKARSA GAME DIFFICULTILERI SIL -_-
const ent_type = "enemy"

#CHILDREN
onready var attack_area = $AttackArea
onready var attack_light = $AttackArea/Light
onready var sprite = $Sprite
onready var toprak = $TozToprak

#STATE MACHINE AND TIMERS
enum states {ACTIVE, AIMING, DEAD}
var current_state = states.ACTIVE

var aim_timer_def = 1
var aim_timer = aim_timer_def

#MOVEMENT VARIABLES
var movement_vector = Vector2(0,-1)
var speed = 0.8*(GlobalUtility.game_difficulty)

var target : Object
var target_in_view = false

#VISUAL
var skyline_offset = 84
onready var dead_texture = preload("res://sprites/karakter/Dusman_ded.png")

func _ready():
	attack_area.scale *= 1 + 0.2 * GlobalUtility.game_difficulty

func _process(delta):
	#state machine
	match current_state:
		states.ACTIVE:
			active_loop(delta)
		states.AIMING:
			aiming_loop(delta)
		states.DEAD:
			dead_loop(delta)

#GENERAL FUNCTIONS
func fire_weapon():
	if GlobalUtility.player_dead:
		return
	target.get_killed()
	print("target ded and I'm " + str(name))
	$Gunshot.play()

func look_at_target():
	var vector_to_target = target.global_position - global_position
	attack_area.rotation = lerp_angle(attack_area.rotation, vector_to_target.angle(),0.1*(GlobalUtility.game_difficulty))

func reset_aim_timer():
	aim_timer = aim_timer_def*(1/GlobalUtility.game_difficulty)

func move_around(move_speed):
	movement_vector = Vector2(1,0).rotated(attack_area.rotation)
	position += movement_vector*move_speed

func get_harvested():
	$CollisionShape2D.set_deferred("disabled", true)
	if current_state == states.DEAD:
		return
	switch_to_dead()

func movement_vfx():
	sprite.scale.y = 0.9 + sin(speed/240)/2 + sin(Time.get_ticks_msec()*0.008)/64*log(4 + speed)
	toprak.process_material.scale = log(2 + 0.25*speed)
	if position.y <= skyline_offset:
		scale = Vector2.ONE * clamp((position.y+skyline_offset)/64, 0 ,1)
		toprak.process_material.scale = 0
		if scale.x == 0:
			queue_free()

#STATE FUNCTIONS
func switch_to_active():
	$Alert.visible = false
	attack_light.color = Color(1,1,1,1)
	current_state = states.ACTIVE

func active_loop(delta):
	move_around(speed)
	movement_vfx()
	if target_in_view and target.can_be_seen:
		switch_to_aiming()

func switch_to_aiming():
	$Alert.visible = true
	attack_light.color = Color(1,0,0,1)
	reset_aim_timer()
	current_state = states.AIMING

func aiming_loop(delta):
	move_around(speed/4)
	aim_timer -= delta
	if !target.current_state == target.states.DASH:
		look_at_target()
	
	if !target_in_view or target.current_state == target.states.HARVESTED or target.current_state == target.states.DEAD:
		switch_to_active()
	
	elif aim_timer <= 0:
		fire_weapon()
		switch_to_active()

func switch_to_dead():
	$Alert.visible = false
	current_state = states.DEAD
	sprite.texture = dead_texture
	modulate = Color(0.5,0,0,0.8)
	attack_area.visible = false

func dead_loop(delta):
	pass

func _on_AttackArea_body_entered(body):
	if body.get("ent_type") == "player":
		target = body
		target_in_view = true

func _on_AttackArea_body_exited(body):
	if body.get("ent_type") == "player":
		target_in_view = false

func _on_Enemy_body_entered(body):
	if body.get("ent_type") == "player" and current_state != states.DEAD:
		fire_weapon()

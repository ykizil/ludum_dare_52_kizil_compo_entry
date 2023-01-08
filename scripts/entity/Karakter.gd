extends RigidBody2D

const ent_type = "player"

var speed = 400 #speed related variables
var dash_speed = 600

var can_be_seen = true

#CHILDREN
onready var stealth_area = $StealthArea
onready var sprite = $Sprite
onready var toprak = $TozToprak
onready var goz2 = $Sprite/Goz2
onready var death_sprite = $DeathSprite

#STATE MACHINE AND TIMERS
enum states {IDLE, IDLE_INV, MOVING, DASH, DEAD, HARVESTED}
var current_state = states.IDLE_INV

#timer for dash cooldown
var dash_timer_def = 0.6
var dash_timer = dash_timer_def

#input vector for movement
var input_vector = Vector2.ZERO

func _ready():
	GlobalUtility.player = self

func _process(delta):
	
	GlobalUtility.player_dead = current_state == states.DEAD or current_state == states.HARVESTED
	if GlobalUtility.player_dead:
		if Input.is_action_just_pressed("reset"):
			GlobalUtility.start_game()
		if Input.is_action_just_pressed("go_menu"):
			GlobalUtility.end_game()
	
	#print(states.keys()[current_state])
	movement_vfx()
	if int(GlobalUtility.game_difficulty*60) - 60 >= 120:
		$CollisionShape2D.set_deferred("disabled",true)
	#state machine
	match current_state:
		states.IDLE:
			idle_loop(delta)
		states.IDLE_INV:
			invisible_loop(delta)
		states.MOVING:
			moving_loop(delta)
		states.DASH:
			dash_loop(delta)
		states.DEAD:
			dead_loop(delta)
		states.HARVESTED:
			harvested_loop(delta)

#GENERAL FUNCTIONS
func check_movement(delta):#check if the player is moving
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	#if the player is pressing movement keys, move and switch to moving state. else check if the player is idling in grass or not
	if input_vector.length() > 0:
		apply_central_impulse(input_vector.normalized()*speed*delta)
		switch_to_moving()
	else:
		check_grass()

func check_dash():#check if the player is trying to dash
	if Input.is_action_just_pressed("dash"):
		dash(input_vector.normalized())

func dash(dash_vector):#apply dash and switch to dash state
	apply_central_impulse(dash_vector*dash_speed)
	switch_to_dash()

func check_grass(): #check if the player is in grass or not, if in grass switch to invisible else to idle
	for area in stealth_area.get_overlapping_areas():
		if area.get("ent_type") == "grass":
			switch_to_invisible()
			return
	
	switch_to_idle()

#VISUAL FUNCTIONS
func movement_vfx():
	sprite.scale.y = 0.8 + sin(linear_velocity.length()/240)/2 + sin(Time.get_ticks_msec()*0.008)/64*log(4 + linear_velocity.length())
	death_sprite.scale.y = sprite.scale.y
	toprak.process_material.scale = log(4 + 0.25*linear_velocity.length())
	goz2.position = input_vector

func get_harvested():
	$CollisionShape2D.set_deferred("disabled",true)
	if current_state == states.HARVESTED:
		return
	switch_to_harvested()

func get_killed():
	#$CollisionShape2D.set_deferred("disabled",true)
	if current_state == states.DEAD or current_state == states.HARVESTED:
		return
	switch_to_dead()

#STATE FUNCTIONS
func switch_to_idle():
	current_state = states.IDLE
	can_be_seen = true

func idle_loop(delta):
	check_movement(delta)

func switch_to_invisible():
	current_state = states.IDLE_INV
	can_be_seen = false

func invisible_loop(delta):
	check_movement(delta)

func switch_to_moving():
	current_state = states.MOVING
	can_be_seen = true

func moving_loop(delta):
	check_movement(delta)
	check_dash()

func switch_to_dash():
	dash_timer = dash_timer_def
	current_state = states.DASH
	can_be_seen = false

func dash_loop(delta):
	dash_timer -= delta
	if dash_timer <= 0:
		switch_to_idle()

func switch_to_dead():
	sprite.visible = false
	death_sprite.visible = true
	death_sprite.play("DEATH")
	current_state = states.DEAD
	can_be_seen = false

func dead_loop(delta):
	if death_sprite.frame >= 3:
		death_sprite.stop()
		death_sprite.frame = 3

func switch_to_harvested():
	current_state = states.HARVESTED
	sprite.visible = false
	death_sprite.visible = true
	death_sprite.frame = 3
	modulate = Color(0.5,0,0,0.8)
	can_be_seen = false

func harvested_loop(delta):
	pass

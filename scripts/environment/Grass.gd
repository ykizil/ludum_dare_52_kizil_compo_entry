extends Area2D

var ent_type = "grass" #define object as grass

#PRELOAD
var grass_texture = preload("res://sprites/environment/grass.png") #grass texture preloads...
var grass_harv_texture = preload("res://sprites/environment/grass_harv.png")

onready var rng = RandomNumberGenerator.new()

#CHILDREN
onready var sprite = $Sprite

#STATE MACHINE AND TIMERS
enum states {GRASS, HARVESTED}
var current_state = states.GRASS

var recover_timer_def = 10 #timer for recovery from harvest
var recover_timer = recover_timer_def

#VFX
var wind_effect

#READY
func _ready():
	rng.randomize()
	wind_effect = rng.randf_range(1,1.2)
	sprite.offset.y = rng.randf_range(-2,2)

#PROCESS
func _process(delta):
	
	#state machine...
	match current_state:
		states.GRASS:
			grass_loop(delta)
		states.HARVESTED:
			harvested_loop(delta)

#GENERAL FUNCTIONS
func texture_swap(new_texture : Texture): #set new texture
	sprite.texture = new_texture

func count_recover_timer(delta): #count down the timer for harvest recovery
	recover_timer -= delta
	if recover_timer <= 0:
		reset_recover_timer()
		switch_to_grass()

func reset_recover_timer(): #reset the timer for harvest recovery
	recover_timer = (recover_timer_def + rng.randf_range(0,5)) * (GlobalUtility.game_difficulty)  

func get_harvested(): #get harvested / die
	switch_to_harvested()
	reset_recover_timer()

func movement_vfx():
	sprite.offset.x += sin(Time.get_ticks_msec()*0.01*GlobalUtility.game_difficulty*wind_effect)/4*GlobalUtility.game_difficulty

#STATE FUNCTIONS
func switch_to_grass():
	ent_type = "grass"
	z_index = 0
	current_state = states.GRASS
	texture_swap(grass_texture)

func grass_loop(delta):
	movement_vfx()

func switch_to_harvested():
	ent_type = "grass_harv"
	z_index = -100
	current_state = states.HARVESTED
	texture_swap(grass_harv_texture)

func harvested_loop(delta):
	count_recover_timer(delta)

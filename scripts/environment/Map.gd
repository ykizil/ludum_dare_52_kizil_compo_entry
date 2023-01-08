extends YSort

export var area_size_x = 16
export var area_size_y = 16
var tile_size = 24

var combine_spawn_size = 96
var combine_spawn_left_anchor = -336*2
var combine_spawn_right_anchor = 720*2
var combine_spawn_top_offset = 24
var combine_speed = 200

var rng = RandomNumberGenerator.new()

var grass_scene = preload("res://scenes/Grass.tscn")

var enemy_scene = preload("res://scenes/entity/Enemy.tscn")
var combine_scene = preload("res://scenes/entity/Combine.tscn")

var spawn_timer_def = 20
var spawn_timer = 4

func _ready():
	rng.randomize()
	for tile_x in range(area_size_x):
		for tile_y in range(area_size_y):
				add_entity(grass_scene, Vector2(tile_x,tile_y)*tile_size)

func _process(delta):
	count_spawn_timer(delta)
	
func count_spawn_timer(delta):
	if GlobalUtility.player_dead:
		return
	spawn_timer -= delta
	if spawn_timer <= 0:
		reset_spawn_timer()
		spawn_combine()
		for i in range(rng.randi_range(1,2)):
			spawn_enemy()

func reset_spawn_timer():
	spawn_timer = spawn_timer_def*(1/(2*GlobalUtility.game_difficulty))

func spawn_combine():
	var combine_spawn_left_side = rng.randi_range(0,1)
	var combine_spawn_pos_select = rng.randi_range(0,3)
	
	if combine_spawn_left_side:
		var new_combine = add_entity(combine_scene, Vector2(combine_spawn_left_anchor, combine_spawn_top_offset + combine_spawn_pos_select*combine_spawn_size))
		new_combine.to_left = false
		new_combine.speed = combine_speed*GlobalUtility.game_difficulty
	else:
		var new_combine = add_entity(combine_scene, Vector2(combine_spawn_right_anchor, combine_spawn_top_offset + (combine_spawn_pos_select + 0.5)*combine_spawn_size))
		new_combine.to_left = true
		new_combine.speed = combine_speed*GlobalUtility.game_difficulty

func spawn_enemy():
	var new_enemy = add_entity(enemy_scene, GlobalUtility.player.global_position + Vector2(900,0).rotated(rng.randf_range(0,PI)))
	new_enemy.attack_area.look_at(GlobalUtility.player.global_position + Vector2(rng.randf_range(-60,60),rng.randf_range(-60,60))*(1/GlobalUtility.game_difficulty))

func add_entity(entity_scene, entity_pos):
	var entity = entity_scene.instance()
	add_child(entity)
	entity.position = entity_pos
	return entity

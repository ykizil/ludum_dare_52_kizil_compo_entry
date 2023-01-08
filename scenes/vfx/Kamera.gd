extends Camera2D

onready var intial_pos = self.global_position
onready var desired_pos = self.global_position

onready var rng = RandomNumberGenerator.new()
var shake_vector = Vector2.ZERO

func _ready():
	GlobalUtility.kamera = self
	rng.randomize()

func _process(delta):
	global_position -= (global_position-desired_pos)/2
	shake_vector_control()

func camera_shake(strength):
	shake_vector += Vector2.ONE*strength

func shake_vector_control():
	shake_vector *= 0.9
	shake_vector = shake_vector.rotated(rng.randf_range(-PI,PI))
	global_position += shake_vector

extends Area2D
class_name ShootAtTargetComponent

const BULLET = preload("res://Max/enemy/Bullet.tscn")
const PACK_OF_RATS = preload("res://Max/pack_of_rats/pack_of_rats.tscn")
@export var vision_radius: float = 200
@export var bullet_speed: float = 6

const default_tune = preload("res://assets/Music/spit-36265.mp3")

@export var fire_audio: AudioStream = default_tune

@export_range(0, 3, 0.05) var fire_rate: float = 0.5
@export_range(0, 3, 0.05) var fire_rate_variance: float = 0.5

@onready var vision_circle_shape = $VisionCircleShape
@onready var fire_rate_timer = $FireRateTimer

#globals do not change
var target
var true_parent
var generated_area_2d

# Called when the node enters the scene tree for the first time.
func _ready():
	true_parent = get_parent()
	
	vision_circle_shape.disabled = false
	
	fire_rate_timer.timeout.connect(_fire_rate_event)
	fire_rate_timer.wait_time = fire_rate

	vision_circle_shape.shape.radius = vision_radius
	
	var temp_bullet = BULLET.instantiate()
	add_child(temp_bullet)
	temp_bullet.visible = false
	generated_area_2d = temp_bullet.create_new_collision_from_image()
	temp_bullet.queue_free()

func play_music():
	var music = AudioStreamPlayer.new()
	add_child(music)
	
	music.stream = fire_audio
	music.play()
	

func shoot_at_target():
	var new_bullet = BULLET.instantiate()
	owner.add_child(new_bullet)
	new_bullet.update_sprite(new_bullet.sprite_2d.texture)
	new_bullet.area_2d = generated_area_2d
	var travel_direction = true_parent.position.direction_to(target.position)
	new_bullet.start(self.position)
	new_bullet.launch(self.bullet_speed, travel_direction, true)

	play_music()

func _fire_rate_event():
	shoot_at_target()
	# Add variance to how often the shots occur
	fire_rate_timer.wait_time = fire_rate + randf_range(-fire_rate_variance, fire_rate_variance)

func _on_body_entered(body):
	if body is PackOfRats:
		target = body
		shoot_at_target()
		fire_rate_timer.start()
		
func _on_body_exited(body):
	if body is PackOfRats:
		target = null
		fire_rate_timer.stop()

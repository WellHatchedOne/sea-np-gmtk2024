extends Node2D
class_name BulletDestination

const BULLET = preload("res://Max/enemy/Bullet.tscn")

@export_range(0,2,0.01) var fire_rate: float = 0.5
@export_range(0,1000,5) var bullet_speed: float = 5
@export_range(0,20,0.25) var bullet_lifetime_seconds: float = 3
@export var bullet_sprite_file: Sprite2D = null
@onready var bullet_sprite = $BulletSprite
@onready var color_rect = $ColorRect

@onready var area_2d = $Area2D
var new_bullet_shape

var generated_area_2d = null

# @onready var timer = $Timer
var timer
@onready var bullet_origin = $"../BulletOrigin"

func _ready():
	if bullet_sprite_file:
		bullet_sprite.texture = bullet_sprite_file.texture
	
	var temp_bullet = BULLET.instantiate()
	add_child(temp_bullet)
	temp_bullet.visible = false
	temp_bullet.update_sprite(bullet_sprite.texture)
	generated_area_2d = temp_bullet.create_new_collision_from_image()
	temp_bullet.queue_free()
	
	timer = self.get_node("Timer")
	timer.timeout.connect(_fire_rate_timer)
	timer.wait_time = fire_rate
	
func start_firing():
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _fire_rate_timer():
	fire()

func fire():
	var new_bullet = BULLET.instantiate()
	get_parent().get_parent().add_child(new_bullet)
	new_bullet.isEnemyBullet = false
	if get_parent().bullet_texture == null:
		new_bullet.update_sprite(bullet_sprite.texture)
	else:
		new_bullet.update_sprite(get_parent().bullet_texture)
	new_bullet.area_2d = generated_area_2d
	var travel_direction = bullet_origin.position.direction_to(self.position)
	new_bullet.start(bullet_origin.position)
	new_bullet.launch(self.bullet_speed, travel_direction, true)
	new_bullet.set_lifetime(self.bullet_lifetime_seconds)
	

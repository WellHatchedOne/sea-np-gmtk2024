extends Node2D
class_name RatAbilityController

const BULLET = preload("res://Max/enemy/Bullet.tscn")
@export_range(0,2,0.01) var fire_rate: float = 0.5
@export_range(0,1000,5) var bullet_speed: float = 5
@export_range(0,20,0.25) var bullet_lifetime_seconds: float = 3
@export var debug: bool = false

@export var bullet_texture: Texture = null

var bullet_direction_array: Array[BulletDestination] = []
@onready var bullet_origin = $BulletOrigin

func _ready():	
	for child in self.get_children():
		if child is BulletDestination:
			child.start_firing()
			
			
			child.color_rect.visible = debug
			bullet_origin.color_rect.visible = debug
	

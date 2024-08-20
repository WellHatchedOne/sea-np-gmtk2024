extends Area2D
class_name Bullet

@export var speed: float = 15
@export var damage: float = 25
var direction = Vector2(0,0)
var start_traveling = false

@onready var area_2d = $Area2D
@onready var sprite_2d = $Sprite2D
@onready var timer = $Timer

var isEnemyBullet = true

func _ready():
	
	if get_parent().get_parent() is Rat:
		isEnemyBullet = false
	
	timer.timeout.connect(_end_bullet_after_timer)
	set_lifetime(20)
	
func create_new_collision_from_image() -> Area2D:
	# Update bullet collision based on sprite
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(sprite_2d.texture.get_image())
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, sprite_2d.texture.get_size()))
	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = poly
		collision_polygon.position -= sprite_2d.texture.get_size()/2
		area_2d.call_deferred("add_child", collision_polygon)
	return area_2d

func set_lifetime(seconds_to_disappear):
	timer.wait_time = seconds_to_disappear

func _end_bullet_after_timer():
	pass
	
func update_sprite(new_texture: Texture):
	sprite_2d.texture = new_texture
	create_new_collision_from_image()

func start(pos: Vector2):
	self.position = pos

func face_travel_directions():
	self.rotation = direction.angle()

func launch(speed, direction, should_start):
	
	self.speed = speed
	self.direction = direction
	self.start_traveling = should_start
	face_travel_directions()

func _physics_process(delta):
	if start_traveling:
		position += (direction*speed)*delta
		
func _on_body_entered(body):
	#print(body)
	if body is TileMap:
		self.queue_free()
	
	if body is Rat && isEnemyBullet:
		body._on_hit_by_bullet()
		self.queue_free()
		return
	
	if body is HealthComponent && not isEnemyBullet:
		body.take_damage(self.damage)
		self.queue_free()

# Since new bullet hitbox is a child of the bullet
func _on_area_2d_body_entered(body):
	self._on_body_entered(body)

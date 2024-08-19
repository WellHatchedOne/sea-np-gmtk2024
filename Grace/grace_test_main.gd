extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var speed = 200
	var velocity = Vector2.ZERO # Player's movement vector
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$FireRatAnimatedSprite2D.play()
		$rat.animated_sprite_2d.play()
		$WaterRatAnimatedSprite2D.play()
		$ElectricRatAnimatedSprite2D.play()
		$ToxicRatAnimatedSprite2D.play()
		$WizardRatAnimatedSprite2D.play()
	else:
		$FireRatAnimatedSprite2D.stop()
		$WaterRatAnimatedSprite2D.stop()
		$ElectricRatAnimatedSprite2D.stop()
		$ToxicRatAnimatedSprite2D.stop()
		$WizardRatAnimatedSprite2D.stop()
		$rat.animated_sprite_2d.stop()
		
	$FireRatAnimatedSprite2D.position += velocity * delta
	$WaterRatAnimatedSprite2D.position += velocity * delta
	$ElectricRatAnimatedSprite2D.position += velocity * delta
	$ToxicRatAnimatedSprite2D.position += velocity * delta
	$WizardRatAnimatedSprite2D.position += velocity * delta
	$rat.animated_sprite_2d.position += velocity * delta
	
	if velocity.x != 0:
		$FireRatAnimatedSprite2D.animation = "side"
		$FireRatAnimatedSprite2D.flip_v = false
		$WizardRatAnimatedSprite2D.animation = "side"
		$WizardRatAnimatedSprite2D.flip_v = false
		$rat.animated_sprite_2d.animation = "side"
		$rat.animated_sprite_2d.flip_v = false
		$WaterRatAnimatedSprite2D.animation = "side"
		$WaterRatAnimatedSprite2D.flip_v = false
		$ElectricRatAnimatedSprite2D.animation = "side"
		$ElectricRatAnimatedSprite2D.flip_v = false
		$ToxicRatAnimatedSprite2D.animation = "side"
		$ToxicRatAnimatedSprite2D.flip_v = false
		
		$FireRatAnimatedSprite2D.flip_h = velocity.x < 0
		$WizardRatAnimatedSprite2D.flip_h = velocity.x < 0
		$rat.animated_sprite_2d.flip_h = velocity.x < 0
		$WaterRatAnimatedSprite2D.flip_h = velocity.x < 0
		$ElectricRatAnimatedSprite2D.flip_h = velocity.x < 0
		$ToxicRatAnimatedSprite2D.flip_h = velocity.x < 0
		
	if velocity.y != 0:
		$FireRatAnimatedSprite2D.animation = "up"
		$FireRatAnimatedSprite2D.flip_v = velocity.y > 0
		$WizardRatAnimatedSprite2D.animation = "up"
		$WizardRatAnimatedSprite2D.flip_v = velocity.y > 0
		$rat.animated_sprite_2d.animation = "up"
		$rat.animated_sprite_2d.flip_v = velocity.y > 0
		$WaterRatAnimatedSprite2D.animation = "up"
		$WaterRatAnimatedSprite2D.flip_v = velocity.y > 0
		$ElectricRatAnimatedSprite2D.animation = "up"
		$ElectricRatAnimatedSprite2D.flip_v = velocity.y > 0
		$ToxicRatAnimatedSprite2D.animation = "up"
		$ToxicRatAnimatedSprite2D.flip_v = velocity.y > 0

extends Area2D
class_name RatUpgradeComponent

@export var new_sprite: PackedScene = null
@onready var pickup_sprite_2d = $PickupSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(new_sprite != null, "RatUpgradeComponent does not have an upgrade sprite")
	var new_sprite_instance: AnimatedSprite2D = new_sprite.instantiate()
	add_child(new_sprite_instance)
	pickup_sprite_2d.texture = new_sprite_instance.get_node("Sprite2D").texture
	pickup_sprite_2d.texture
	new_sprite_instance.queue_free()
	
func upgrade_rat(rat: Rat):
	
	if rat.ratType != "basic":
		var pack_of_rats: PackOfRats = rat.get_parent()
		var next_basic_rat = pack_of_rats.return_basic_rat()
		if next_basic_rat != null:
			rat = next_basic_rat
		
	var new_sprite_instance: AnimatedSprite2D = new_sprite.instantiate()
	add_child(new_sprite_instance)
	rat.animated_sprite_2d.sprite_frames = new_sprite_instance.sprite_frames
	
	if rat.has_node("RatAbilityController"):
		rat.get_node("RatAbilityController").queue_free()
		
	var needed_controller = new_sprite_instance.get_node("RatAbilityController").duplicate()
	#new_sprite_instance.remove_child(needed_controller)
	new_sprite_instance.call_deferred("remove_child", new_sprite_instance)
	#rat.call_deferred("add_child", new_sprite_instance)
	rat.add_child(needed_controller)
	rat.ratType = new_sprite_instance.name
	#new_sprite_instance.queue_free()
	
func _on_body_entered(body):
	if body is Rat:
		upgrade_rat(body)
		self.queue_free()

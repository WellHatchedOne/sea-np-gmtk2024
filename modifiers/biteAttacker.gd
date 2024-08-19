extends Area2D

@export var Damage: int = 1

var FRIENDLY_GROUP = "FRIENDLY"
var ENEMY_GROUP = "ENEMY"
var DEBUG = false

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_mask
	pass # Replace with function body.

func attack():
	if DEBUG:
		_make_attack_visible()
	var overlappingBodies = get_overlapping_bodies()
	var target = null
	if get_parent().is_in_group(FRIENDLY_GROUP):
		#print("rat attacking")
		target = getFirstDamageableInGroup(overlappingBodies, ENEMY_GROUP)
	else:
		target = getFirstDamageableInGroup(overlappingBodies, FRIENDLY_GROUP)
	if target != null:
		print("attacking target")
		print(target.get_name())		
		target.damage(Damage)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getFirstDamageableInGroup(overlappingBodies: Array, group: String):
	for body in overlappingBodies:
		if body.get_node("Damageable") != null:
			if body.is_in_group(group):
				return body.get_node("Damageable")
	return null

func _make_attack_visible():
	var colorRect = get_node("ColorRect")
	colorRect.visible = 1
	await get_tree().create_timer(0.25).timeout
	colorRect.visible = 0

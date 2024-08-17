extends Node
class_name Damagable

@export var health: int = 1

	
func _damage(damageValue):
	health = health - damageValue
	if(health < 0):
		_kill()

func _kill():
	# place death particles
	queue_free()
	# play death sound

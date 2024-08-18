extends Node
class_name Damageable

@export var health: int = 1
	
func damage(damageValue):
	health = health - damageValue
	var format_msg = "{characterName} is taking {damangeValue} damage! Prior health = {health}"
	print(format_msg.format({"characterName": get_parent().get_name(), "damageValue": damageValue, "health": health}))
	if(health < 0):
		_kill()

func _kill():
	# Death effect/particles
	# Since this is attached as a chile node, we get the parent and kill that.
	get_parent().queue_free()
	# Play death sound

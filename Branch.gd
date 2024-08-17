extends Node

class_name Branch

var left_child:  Branch
var right_child:  Branch
var position: Vector2i
var size: Vector2i

func _init(position: Vector2i, size: Vector2i):
	self.position = position
	self.size = size

func get_leaves():
	# Each branch can have either zero or two child branches, so:
	# null = false
	# not (false && false) = true
	# not (true && true) = false 
	if not (left_child and right_child):
		return [self]
	else:
		return left_child.get_leaves() + right_child.get_leaves()

func split(remaining: int, paths: Array):
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var split_percent: float = rng.randf_range(0.3,0.7) # splits will be between 30% and 70%
	var split_horizontal: bool = size.y >= size.x # if it is taller than it is wide

	if (split_horizontal):
		# horizontal
		var left_height = int(size.y * split_percent)
		left_child = Branch.new(position, Vector2i(size.x, left_height))
		right_child = Branch.new(
			Vector2i(position.x, position.y + left_height), 
			Vector2i(size.x, size.y - left_height)
		)
	else:
		# vertical
		var left_width = int(size.x * split_percent)
		left_child = Branch.new(position, Vector2i(left_width, size.y))
		right_child = Branch.new(
			Vector2i(position.x + left_width, position.y), 
			Vector2i(size.x - left_width, size.y)
		)
	
	paths.push_back({'left': left_child.get_center(), 'right': right_child.get_center()})

	if(remaining > 0):
		left_child.split(remaining - 1, paths)
		right_child.split(remaining - 1, paths)
		
func self_inside_padding(x: int, y: int, padding: Vector4i):
	return x <= padding.x or y <= padding.y or x >= size.x - padding.z or y >= size.y - padding.w

func get_center() -> Vector2i:
	return Vector2i(position.x + size.x / 2, position.y + size.y / 2)

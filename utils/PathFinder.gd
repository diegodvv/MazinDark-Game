extends Node

class_name PathFinder

var grid_map: GridMap = null
var navigation_id = -1
var a_star: AStar = null
var navigation_points = []
var indexes = {}

func _init(grid_map: GridMap, navigation_id: int):
	self.navigation_id = navigation_id
	self.grid_map = grid_map
	self.a_star = AStar.new()
	
	for cell in grid_map.get_used_cells():
		var id = grid_map.get_cell_item(cell.x, cell.y, cell.z)
		if id == navigation_id:
			var point = Vector3(cell.x, cell.y, cell.z)
			navigation_points.append(point)
			var index = indexes.size()
			indexes[point] = index
			
			a_star.add_point(index, point)
			
	for point in navigation_points:
		var index = get_point_index(point)
		var relative_points = PoolVector3Array([
			Vector3(point.x + 1, point.y, point.z),
			Vector3(point.x - 1, point.y, point.z),
			Vector3(point.x, point.y, point.z - 1),
			Vector3(point.x, point.y, point.z + 1),
		])
		
		for relative_point in relative_points:
			var relative_index = get_point_index(relative_point)
			
			if relative_index == null:
				continue
				
			if a_star.has_point(relative_index):
				a_star.connect_points(index, relative_index)
		
func get_point_index(vector: Vector3):
	if indexes.has(vector):
		return indexes[vector]
		
	return null
	
func find_path(start, target) -> PoolVector3Array:
	var grid_start = grid_map.world_to_map(start)
	var grid_end = grid_map.world_to_map(target)
	grid_start.y = 0
	grid_end.y = 0
	
	var index_start = get_point_index(grid_start)
	var index_end = get_point_index(grid_end)
	
	var path_exists = index_start != null and index_end != null
	if !path_exists:
		return PoolVector3Array()
	
	var a_star_path = a_star.get_point_path(get_point_index(grid_start), get_point_index(grid_end))
	var world_path: PoolVector3Array = []
	for point in a_star_path:
		world_path.append(grid_map.map_to_world(point.x, point.y, point.z))
	
	return world_path

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

extends Node

const TILE_SIZE: int = 32

#godot snappedi wont work so Im making my own
func snapperi(var1: float, var2: int) -> int:
	var result: int = floori(var1 / var2) * var2
	return result

#I might not need it but just in case)
func relative_grid(var1: Vector2, var2: Vector2) -> Vector2:
	var x = (var1.x - var2.x) / TILE_SIZE
	var y = (var1.y - var2.y) / TILE_SIZE
	return Vector2(x, y)

#godot is_approx_equals doesnt work for me for some reason((
func approx_equals(var1, var2, e) -> bool:
	e = abs(e)
	if var1 < (var2 + e) and var1 > (var2 - e):
		return true
	return false

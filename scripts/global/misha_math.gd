extends Node

#godot snappedi wont work so Im making my own
func snapperi(var1: float, var2: int) -> int:
	var result: int = roundi(var1 / var2) * var2
	return result

#godot is_approx_equals doesnt work for me for some reason((
func approx_equals(var1, var2, e) -> bool:
	e = abs(e)
	if var1 < (var2 + e) and var1 > (var2 - e):
		return true
	return false

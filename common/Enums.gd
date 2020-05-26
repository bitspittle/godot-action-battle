extends Node

enum Side { LEFT, RIGHT }
enum Level { UPPER, MIDDLE, LOWER }

static func opposite_side(side) -> int:
	return side + 1 % 2

static func random_level():
	return Util.random_element(Level.values())

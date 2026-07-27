class_name IceData
extends ElementData

func _init() -> void:
	rank = 6
	color = Color(0,.5,1)
	color_name = 'cerulean'
	symbol = 'star'
	spirit = 'peace'
	realm = 'winter'
	pattern = {
		1: [3,5],
		2: [5,7],
		3: [7],
		5: [],
		7: [],
	}

class_name MightData
extends ElementData

func _init() -> void:
	rank = 11
	color = Color(.5,.5,.5)
	color_name = 'gray'
	symbol = 'moon'
	spirit = 'separation'
	realm = 'the night'
	pattern = {
		0: [1,6,7],
		1: [7],
		3: [4,5],
		4: [5,6],
		5: [6,7],
		6: [7],
		7: [],
	}

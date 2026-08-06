class_name LightData
extends ElementData

func _init() -> void:
	rank = 10
	color = Color(1,1,1)
	color_name = 'white'
	symbol = 'sun'
	spirit = 'glory'
	realm = 'the universe'
	pattern = {
		0: [2,6],
		1: [3,7],
		2: [4],
		3: [5],
		4: [6],
		5: [7],
		6: [],
		7: [],
	}

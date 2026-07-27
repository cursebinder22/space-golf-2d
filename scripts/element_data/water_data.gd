class_name WaterData
extends ElementData

func _init() -> void:
	rank = 7
	color = Color(0,0,1)
	color_name = 'cobalt'
	symbol = 'droplet'
	spirit = 'sorrow'
	realm = 'the deep'
	pattern = {
		2: [5,6,7],
		5: [6,7],
		6: [7],
		7: [],
	}

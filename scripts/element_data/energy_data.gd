class_name EnergyData
extends ElementData

func _init() -> void:
	rank = 3
	color = Color(1,1,0)
	color_name = 'yellow'
	symbol = 'bolt'
	spirit = 'thrill'
	realm = 'power'
	pattern = {
		0: [4,6],
		1: [5,6],
		2: [4,5],
		4: [],
		5: [],
		6: [],
	}

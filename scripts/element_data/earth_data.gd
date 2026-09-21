class_name EarthData
extends ElementData

func _init() -> void:
	rank = 1
	color = Color(1,0,0)
	color_name = 'red'
	spirit = 'rage'
	realm = 'hell'
	symbol_name = 'volcano'
	symbol = {
		0: [1],
		1: [2],
		2: [3,'C'],
		3: [4],
		4: [],
		5: [6,'C'],
		6: [7,'C'],
		7: ['C'],
		'C': [],
	}

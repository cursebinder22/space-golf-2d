class_name AirData
extends ElementData

func _init() -> void:
	rank = 5
	color = Color(0,1,1)
	color_name = 'cyan'
	symbol = 'creature'
	spirit = 'freedom'
	realm = 'heaven'
	pattern = {
		0: [4,5],
		1: ['C'],
		3: ['C'],
		4: [7],
		5: ['C'],
		6: ['C'],
		7: ['C'],
		'C': [],
	}

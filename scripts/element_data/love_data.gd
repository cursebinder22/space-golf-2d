class_name LoveData
extends ElementData

func _init() -> void:
	rank = 9
	color = Color(1,.5,1)
	color_name = 'pink'
	symbol = 'heart'
	spirit = 'safety'
	realm = 'family'
	pattern = {
		0: [1,6],
		1: [6,'C'],
		3: [4,6,'C'],
		4: [6],
		6: ['C'],
		'C': [],
	}

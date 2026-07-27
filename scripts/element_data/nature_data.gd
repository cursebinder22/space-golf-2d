class_name NatureData
extends ElementData

func _init() -> void:
	rank = 4
	color = Color(0,1,0)
	color_name = 'green'
	symbol = 'tree'
	spirit = 'joy'
	realm = 'life'
	pattern = {
		0: [2,4],
		2: [4,5,7],
		4: [],
		5: ['C'],
		6: ['C'],
		7: ['C'],
		'C': [],
	}

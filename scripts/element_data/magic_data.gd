class_name MagicData
extends ElementData

func _init() -> void:
	rank = 8
	color = Color(.5,0,1)
	color_name = 'purple'
	symbol = 'crystal'
	spirit = 'beauty'
	realm = 'the underworld'
	pattern = {
		0: [1,4,6],
		1: [3,'C'],
		3: [4,'C'],
		4: [6,'C'],
		6: ['C'],
		'C': [],
	}

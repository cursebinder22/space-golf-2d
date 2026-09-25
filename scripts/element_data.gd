class_name ElementData
extends Resource

var rank: int = 0
var color: Color = Color.TRANSPARENT
var symbol: Dictionary = {
}

func _init(element: Global.Element) -> void:
	match element:
		Global.Element.EARTH:
			rank = 1
			color = Color(1,0,0)
			symbol = {
				0: [1,7,'C'],
				1: [2],
				3: [4,'C'],
				4: [5,'C'],
				5: ['C'],
				6: [7],
			}
		Global.Element.FIRE:
			rank = 2
			color = Color(1,.5,0)
			symbol = {
				0: [3,5],
				2: [3,5],
				3: [6],
				5: [6],
			}
		Global.Element.ENERGY:
			rank = 3
			color = Color(1,1,0)
			symbol = {
				0: [5,6],
				1: [4,5],
				2: [4,6],
			}
		Global.Element.NATURE:
			rank = 4
			color = Color(0,1,0)
			symbol = {
				0: [2,3,5,6],
				2: [6],
				3: ['C'],
				4: ['C'],
				5: ['C'],
			}
		Global.Element.AIR:
			rank = 5
			color = Color(0,1,1)
			symbol = {
				1: [5],
				2: [5,6],
				3: [6,7],
				4: ['C'],
			}
		Global.Element.ICE:
			rank = 6
			color = Color(0,.5,1)
			symbol = {
				0: [3,5],
				1: [5,7],
				3: [7],
			}
		Global.Element.WATER:
			rank = 7
			color = Color(0,0,1)
			symbol = {
				0: [3,4,5],
				3: [4,5],
				4: [5]
			}
		Global.Element.MAGIC:
			rank = 8
			color = Color(.5,0,1)
			symbol = {
				1: [2,'C',7],
				2: [4,6],
				4: [6,'C'],
				6: [7],
				7: ['C'],
			}
		Global.Element.LOVE:
			rank = 9
			color = Color(1,.5,1)
			symbol = {
				1: [2,4,'C'],
				2: [4],
				4: [6,7,'C'],
				6: [7],
				7: ['C']
			}
		Global.Element.LIGHT:
			rank = 10
			color = Color(1,1,1)
			symbol = {
				0: [2,6],
				1: [3,7],
				2: [4],
				3: [5],
				4: [6],
				5: [7]
			}
		Global.Element.MIGHT:
			rank = 11
			color = Color(.5,.5,.5)
			symbol = {
				1: [2,3],
				2: [3,5],
				3: [4,6],
				4: [5],
				5: [6,7],
				6: [7]
			}
		Global.Element.SIGHT:
			rank = 12
			color = Color(.25,.25,.25)
			symbol = {
				0: [4],
				1: [6],
				2: [5,7],
				3: [6],
			}

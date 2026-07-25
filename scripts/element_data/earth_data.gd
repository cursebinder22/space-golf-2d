extends Node

const friction: float = FrictionTypes.low
const row: int = 0
const column: int = 0
const order: int = 1
const color: Color = Color(1,0,0)
const color_name: String = 'red'
const symbol: String = 'volcano'
const aspect: String = 'rage'
const realm: String = 'hell'
const pattern: Dictionary = {
	0: [1],
	1: [2],
	2: [3,'C'],
	3: [4],
	4: [],
	5: [6,7,'C'],
	6: [7,'C'],
	7: ['C'],
	'C': []
}

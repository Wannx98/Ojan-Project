extends Resource
class_name Quest

enum Status {
	LOCKED,
	ACTIVE,
	COMPLETED
}

@export var id: String
@export var title: String
@export_multiline var description: String

@export var type: String
@export var target: String

@export var goal: int = 1
@export var progress: int = 0

@export var status: Status = Status.LOCKED
@export var next_quest_id: String = "" 

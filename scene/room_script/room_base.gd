extends Node2D
class_name Room

@export_group("Doors")
@export var doors: Array[Node] = []

@export_group("NPCs")
@export var npcs: Array[Node] = []

@export_group("Spawn")
@export var default_spawn: Marker2D

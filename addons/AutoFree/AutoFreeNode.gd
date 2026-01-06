@tool
extends Node

var _timer: Timer


@export_category("Auto Start")

## Automatically start countdown until deletion.
@export var autostart: bool = true


@export_category("Timing")

## Time (in seconds) before freeing starts.
@export var free_after_seconds: float = 1.0


@export_category("Target")

## Node to destroy. If empty, this node is used.
@export var target: NodePath

## Also destroy this AutoFree node when the target is freed.
@export var free_self: bool = true


@export_category("Signal Trigger")

## Signal name that causes countdown to start. Leave empty to disable.
@export var free_on_signal: StringName

## Node that emits the signal. Required if free_on_signal is set.
@export var signal_emitter: NodePath


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if not free_on_signal.is_empty():
		_connect_signal()
	
	if autostart:
		start_free_countdown()
func start_free_countdown() -> void:
	if free_after_seconds <= 0.0:
		return
	if _timer and _timer.is_inside_tree():
		return
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = free_after_seconds
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)
	_timer.start()


func stop_free_countdown() -> void:
	if _timer and _timer.is_inside_tree():
		_timer.stop()
		_timer.queue_free()
		_timer = null


func _on_timeout():
	stop_free_countdown()
	if !target.is_empty():
		get_node_or_null(target).queue_free()
	if free_self:
		queue_free()

func _connect_signal() -> void:
	var emitter := get_node_or_null(signal_emitter)
	if emitter == null:
		push_warning("AutoFree: signal_emitter not found")
		return
	if not emitter.has_signal(free_on_signal):
		push_warning("AutoFree: emitter has no signal '%s'" % free_on_signal)
		return
	emitter.connect(free_on_signal, Callable(self, "start_free_countdown"))

using Godot;
using System;

public partial class player_movement : CharacterBody2D
{
	bool has_moved = false;
	public override void _PhysicsProcess(double delta)
	{
		Vector2 direction = Input.GetVector("move_left", "move_right", "move_up", "move_down");
		if (direction != Vector2.Zero && has_moved == false)
		{
			Position += 32 * direction;
			has_moved = true;
		}
		if (has_moved == true)
		{
			_Ready();
		}
	}
	
	public override void _Ready()
	{
		var timer = GetTree().CreateTimer(1f);
		timer.Timeout += OnTimerTimeout;
	}
	private void OnTimerTimeout()
	{
		has_moved = false;
	}
}

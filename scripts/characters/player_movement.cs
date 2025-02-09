using Godot;
using System;
using System.Threading.Tasks;

public partial class player_movement : StaticBody2D
{
	//important varibles
	[Export]
	public int TileSize { get; set; } = 64;
	bool has_moved = false;
	
	//input handling 
	public Vector2 GetInput()
	{

	   Vector2 direction = Input.GetVector("move_left", "move_right", "move_up", "move_down");
	   return direction;
		
	}
	/*movement method 
	TODO 	- Implement TestMove
			- fix the turns (kill me)
	*/
	public void Move(Vector2 direction) { 
		if (has_moved == true)
		{
			//miserable implemntation of turns (does not work)
				DelayMethod();
		}
		else if (direction != Vector2.Zero && has_moved == false)
		{
			direction = direction.Normalized();
			Position += TileSize * direction;
			Position = Position.Snapped(Vector2.One * TileSize);
			has_moved = true;
		}
	}
	//delay method to create turns (work in progress)
	private async void DelayMethod()
{
	var timer = GetTree().CreateTimer(4f);
	await Task.Delay(TimeSpan.FromMilliseconds(1));
	timer.Timeout += OnTimerTimeout;
}


	public override void _PhysicsProcess(double delta)
	{
		Vector2 direction = GetInput();
		Move(direction);
		//MoveAndSlide();
	}
	
	public override void _Ready()
	{
		Position = Position.Snapped(Vector2.One * TileSize);
		Position += Vector2.One * TileSize;
	}
	
	private void OnTimerTimeout()
	{
		has_moved = false;
	}
}

using System;
using System.Threading.Tasks;

public static class AsyncUtils {
	public static async Task WaitUntil(Func<bool> condition, int checkFreqMS = 20, int timeoutMS = -1) {
		bool timeOutEnabled = timeoutMS > 0;
		
		int elapsedMS = 0;
		
		while (!condition()) 
		{
			await Task.Delay(checkFreqMS);
			
			if (timeOutEnabled)
			{
				elapsedMS += checkFreqMS;
			
				if (elapsedMS >= timeoutMS) throw new TimeoutException("WaitUntil Timed Out");
			}
		}
	}
	
}

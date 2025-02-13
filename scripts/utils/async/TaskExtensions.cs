using System;
using System.Threading.Tasks;

public static class TaskExtensions {
    public static async Task<TV> Then<T, TV>(this Task<T> task, Func<T, TV> then) {
        var returnedVal = await task;
        return then(returnedVal);
    }
}

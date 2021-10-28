using System;
					
public class TennisApp {
	
	//convert the number of wins into tennis scores
	//why does tennis act like this?
	private static int convertScore(int score) {
		switch (score) {
			case 0: return 0;
			case 1: return 15;
			case 2: return 30;
			case 3: return 40;
			default: return -1;
		}
	}
	
	//I am assuming the wins list is unsorted, and, as such, am not calculating whether a player wins after each addition to the list.
	//(Though if I were, I'd only start checking after the fourth edition to the list, of course.)
	public static string returnScore(string p1name, string p2name, string[] wins) {
		int p1wins = 0;
		int p2wins = 0;
		
		//iterate through the list of wins and tally up the scores
		//ints are easier to workwith.
		foreach(string win in wins) {
			if (win == p1name) {
				p1wins++;	
			} else if (win == p2name) {
				p2wins++;	
			}
		}
		
		if (p1wins >= 4 || p2wins >= 4) {//if either player has entered the endstate
			if (p1wins == p2wins) {//if players are tied
				return "DEUCE";
			} else if (p1wins > p2wins) {//if player 1 is winning
				if (p1wins - 2 >= p2wins) {
					return p1name + " WINS";	
				} else {
					return "ADVANTAGE " + p1name;
				}
			} else {//if player 2 is winning
				if (p2wins - 2 >= p1wins) {
					return p2name + " WINS";	
				} else {
					return "ADVANTAGE " + p2name;
				}
			}
		} else {//if the game is not yet in the endstate, just print out the score
			return p1name + " " + convertScore(p1wins) + " - " + p2name + " " + convertScore(p2wins);
		}
	}
	
	public static void Main() {
		Console.WriteLine(returnScore("P1", "P2", new string[] { "P1", "P1", "P2" }));//P1 30 - P2 15
		Console.WriteLine(returnScore("P1", "P2", new string[] { "P1", "P1", "P1" }));//P1 40 - P2 0
		Console.WriteLine(returnScore("P1", "P2", new string[] { "P1", "P1", "P1", "P2", "P2", "P2" }));//P1 40 - P2 40
		Console.WriteLine(returnScore("P1", "P2", new string[] { "P1" }));//P1 15 - P2 0
		Console.WriteLine(returnScore("P1", "P2", new string[] { "P1", "P1", "P1", "P2", "P2", "P2", "P1" }));//ADVANTAGE P1
		Console.WriteLine(returnScore("P1", "P2", new string[] { "P1", "P1", "P1", "P2", "P2", "P2", "P1", "P2" }));//DEUCE
		Console.WriteLine(returnScore("P1", "P2", new string[] { "P1", "P1", "P1", "P2", "P2", "P2", "P1", "P2", "P2" }));//ADVANTAGE P2
		Console.WriteLine(returnScore("Ben", "Jerry", new string[] { "Ben", "Ben", "Jerry", "Jerry" }));//Ben 30 - Jerry 30
		Console.WriteLine(returnScore("Ben", "Jerry", new string[] { }));//Ben 0 - Jerry 0
		Console.WriteLine(returnScore("Ben", "Jerry", new string[] { "Ben", "Ben", "Ben", "Ben", "Jerry", "Jerry", "Jerry" }));//ADVANTAGE Ben
		Console.WriteLine(returnScore("Ben", "Jerry", new string[] { "Ben", "Ben", "Ben", "Ben", "Jerry", "Jerry" }));//Ben WINS
		Console.WriteLine(returnScore("Ben", "Jerry", new string[] { "Jerry", "Jerry", "Jerry", "Jerry" }));//Jerry WINS
		Console.WriteLine(returnScore("Ben", "Jerry", new string[] { "Jerry", "Jerry", "Jerry", "Jerry", "Jerry", "Jerry", "Ben", "Ben", "Ben", "Ben" }));//Jerry WINS
	}
}
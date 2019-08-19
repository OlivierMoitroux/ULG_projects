import java.util.Random;
import java.util.concurrent.TimeUnit;
import java.util.Date;

/**
 * The <code> Mastermind </code> class:
 * <ul>
 * <li> Defines a set of rules for the Mastermind game
 * <li> Defines a set of variables to store informations about the party being played
 * <li> Exposes a set of functions to interact with the game
 * <li> Does not manage any web communication mechanism
 * <li> Supports only Protocol1 at the time
 * <li> Is almost the same as in the project 1
 * </ul>
 * 
 * @author Olivier Moitroux & Thomas Vieslet
 * @version 1
 * @see Protocol 
 * 
 */
public class Mastermind {
	
	/* General rules of the game */
	public static final short ALLOWED_TURN = 12;
	public static final short CLR_2_GUESS = 4;
	protected static final String[] colors = {"red", "blue", "yellow", "green",
			"white", "black"};
	
	
	/* Set of variables to manage a party */
	protected short turnNo;
	protected String[] secretClrs;
	
	protected int crctColorsWellPlaced;
	protected int crctColorsBadPlaced;
	
	protected String[][] clrPropHistory;
	/** flags are [number of correct clrs @ the right place, number of correct colors @ the wrong place] */
	protected String[][] flagsHistory;
	
	protected Date date;
	
	/* Constructor */
	public Mastermind() {
		secretClrs = new String[CLR_2_GUESS];
		this.fill_random_clrs();
		this.date = new Date();
		clrPropHistory = new String[ALLOWED_TURN][CLR_2_GUESS];
		flagsHistory = new String[ALLOWED_TURN][CLR_2_GUESS];
	}
	
	
	/**
	 * <code>Date get_date()</code> 
	 * @return last date set
	 */
	public Date get_date() {
		return date;
	}
	
	/**
	 * <code>update_date()</code> 
	 */
	public void update_date(){
		date = new Date();
	}
	
	/**
	 * <code>long time_elapsed()</code> 
	 * @return the time elapsed in minutes
	 */
	public long time_elapsed(){
		Date now = new Date();
		long diff = now.getTime() - date.getTime();
		return TimeUnit.MILLISECONDS.toSeconds(diff);
	}
	
	/**
	 * <code>short get_turnNo()</code> 
	 * @return the current turn number
	 */
	public short get_turnNo() { return turnNo; }
	
	/**
	 * <code>int get_no_colors()</code> 
	 * @return the number of colors available
	 */
	public int get_no_colors() { return colors.length; }
	
	
	public String[][] get_clrPropHistory() { return clrPropHistory;}
	
	public String[][] get_flagsHistory() { return flagsHistory;}
	
	
	/**
	 * <code>void set_turnNo()</code> </br>
	 * @param currTurn - The current turn number 
	 */
	public void set_turnNo(short currTurn) { turnNo = currTurn; }
	
	/**
	 * <code>void inc_turnNo()</code></br>
	 * Increment the turn number
	 */
	public void inc_turnNo() { turnNo++; }
		
	
	/**
	 * <code>boolean  is_won()</code></br>
	 * @return true if all the colors were guessed, false otherwise
	 */
	public boolean is_won() { return crctColorsWellPlaced == CLR_2_GUESS; }
	
	/**
	 * <code> boolean is_lost()</code></br>
	 * @return true if all turns have been played, false otherwise
	 */
	public boolean is_lost(){ return turnNo == ALLOWED_TURN; }
	
	/**
	 * <code> String[] get_colors()</code></br>
	 * Get the vector of colors name 
	 * @return colors - Vector of string that stores the colors name
	 */
	public static String[] get_colors(){ return colors; }
	
	/**
	 * <code>void reset_history()</code></br>
	 * Resets flags history and colors history
	 */
	public void reset_history() {
		for(int i = 0; i < ALLOWED_TURN; i++) {
			int j;
			for(j = 0 ; j < CLR_2_GUESS ; j++)
				clrPropHistory[i][j] = "";
			
			for(j = 0 ; j < 2 ; j++)
				flagsHistory[i][j] = "";
		}
	}
	
	/**
	 * <code>void fill_random_clrs()</code></br>
	 * Fills the secret combination of colors with random colors
	 */
	void fill_random_clrs() {
		
		Random rand = new Random();
		
		for (int i = 0; i < CLR_2_GUESS; i++) {
			// String randClr = colors[rand.nextInt(colors.length)];
			secretClrs[i] = colors[rand.nextInt(colors.length)];
		}
	}
	
	/**
	 * <code>display_secretClrs()</code></br>
	 * Displays the secret combination of colors on the console 
	 */
	void display_secretClrs() {
		
		System.out.print("Secret combination of colors : ");
		
		for (int i = 0; i < CLR_2_GUESS ; i++)
			System.out.print(secretClrs[i] + " ");
		
		System.out.println();
	}
	
	/**
	 * <code> void save2History(String[] clientClrProp, String[] flags)</code></br>
	 * Saves to history the last colors proposition (for the current turn only!)
	 * @param clientClrProp - The vector of colors proposed:[clr_0, ..., clr_n-1]
	 * @param flags - Array of flags: 
	 * [number of correct clrs @ the right place, number of correct colors @ the wrong place]
	 * @throws MastermindException 
	 */
	void save2History(String[] clientClrProp, String[] flags) throws MastermindException {		
		try{
			
			int crctClrsWellPlaced = Integer.parseInt(flags[0]);
			int crctClrsBadPlaced = Integer.parseInt(flags[1]);
			
			for(int i = 0; i < CLR_2_GUESS ; i++){
				clrPropHistory[turnNo][i] = clientClrProp[i];
				if(crctClrsWellPlaced > 0){
					flagsHistory[turnNo][i] = "Red";
					crctClrsWellPlaced--;
				}
				else if(crctClrsBadPlaced > 0){
					flagsHistory[turnNo][i] = "Black";
					crctClrsBadPlaced--;
				}
				else flagsHistory[turnNo][i] = "LightGrey";
			}
			this.turnNo++;
		}
		catch(Exception e){
			throw new MastermindException("Impossible to save to history");
		}
		
	}
	
	/**
	 * <code>String[] compute_flags(String[] clientClrProp)</code></br>
	 * Compute the flags based on the colors proposition
	 * @param clientClrProp - The vector of colors proposed:[clr_0, ..., clr_n-1]
	 * @return [number of correct clrs @ the right place, number of correct colors @ the wrong place]
	 * @throws MastermindException 
	 */
	String[] compute_flags(String[] clientClrProp) throws MastermindException {
		
		if(clientClrProp.length != CLR_2_GUESS)
			throw new MastermindException("Number of colors is wrong");
		
		crctColorsWellPlaced = 0;
		crctColorsBadPlaced = 0;
		
		// To keep trace of which colors in the secret comb have been correctly guessed
		boolean[] matched =  new boolean[CLR_2_GUESS];
		
		// To keep trace of which colors we have already attributed a flag
		boolean[] checked = new boolean[CLR_2_GUESS];
		
		
		for(int i = 0; i < CLR_2_GUESS ; i++) {
			if(clientClrProp[i].equals(secretClrs[i])) {
				crctColorsWellPlaced++;
				matched[i] = checked[i] = true;
			}
		}
		
		for (int i = 0; i < CLR_2_GUESS; i++) {
			if (matched[i] == false) {
				for(int j = 0; j < CLR_2_GUESS ; j++) {
					/*
					 * !checked[j] <=> if we didn't record a flag for this color
					 * clrs[j] == secretClrs[i] <=> if the color is good ...
					 * i != j <=> ... but not correctly placed
					 */
					if(!checked[j] && clientClrProp[j].equals(secretClrs[i]) && i != j) {
						crctColorsBadPlaced++;
						// This one is marked checked, it can't count twice or more for the same flag
						checked[j] = true;
						break;
					}
				}
			}
		}
		
		/*
		 * [!] Notes [!] : 
		 * - If a color is well placed, it can't be marked as good color not at the right spot
		 * - Let a given color appears once in the secret combination. If the user inputs two of this same color but none
		 * of them are in the right spot, then crctColorsBadPlaced will be incremented only once and not twice !
		 * - By color, I mean a "physical colored pin", not the color in general !
		 * Perhaps I'm wrong but that's how I have always interpreted the Mastermind rules (easier to establish strategies)...
		 *  but I couldn't find clear official rules ...
		 * 
		 * Examples of how I interpret the rules: 
		 * secretClrs = [red, white, red, black]
		 * [red, blue, white, white] => [1,1]
		 * secretClrs = [red, white, red, white]
		 * [green, red, white, red] => flags = [0, 3]
		 * [red, blue, white, white] => flags =[2, 1]
		 * [white, red, white, red] => [0,4]
		 */
		
		String[] ret = {Integer.toString(crctColorsWellPlaced), Integer.toString(crctColorsBadPlaced)};

		return ret;
	}
	
}

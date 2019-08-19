
/**
 * The <code> MastermindException </code> class is a custom exception
 * for illegal operations or unexpected operations in the Mastermind game
 * 
 * @author Olivier Moitroux
 * @version 1
 * @see Mastermind
 * @see MastermindClient 
 * @see MastermindServer
 * 
 */
public class MastermindException extends Exception {

	private static final long serialVersionUID = 1L;

	public MastermindException() {
		super("HTTP Version Not Supported");
	}
	
	public MastermindException (String errMsg){
		super(errMsg);
	}
}

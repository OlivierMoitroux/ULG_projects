
public class LengthRequiredException extends Exception {

	private static final long serialVersionUID = 1L;

	public LengthRequiredException() {
		super("Length Required"); // change name
	}
	
	public LengthRequiredException (String errMsg){
		super(errMsg);
	}
	
	public int get_errCode(){
		return 411;
	}
}
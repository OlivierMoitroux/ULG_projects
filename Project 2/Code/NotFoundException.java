
public class NotFoundException extends Exception {

	private static final long serialVersionUID = 1L;

	public NotFoundException() {
		super("Bad Request");
	}
	
	public NotFoundException (String errMsg){
		super(errMsg);
	}
	
	public int get_errCode(){
		return 404;
	}
}


public class BadRequestException extends Exception {

		private static final long serialVersionUID = 1L;

		public BadRequestException() {}
		
		public BadRequestException (String errMsg){
			super(errMsg);
		}
		
		public int get_errCode(){
			return 400;
		}
}

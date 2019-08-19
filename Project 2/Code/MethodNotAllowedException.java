
public class MethodNotAllowedException extends Exception {

		private static final long serialVersionUID = 1L;

		public MethodNotAllowedException() {
			super("Method Not Allowed");
		}
		
		public MethodNotAllowedException (String errMsg){
			super(errMsg);
		}
		
		public int get_errCode(){
			return 405;
		}
}
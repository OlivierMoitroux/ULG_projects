
public class HttpVersionNotSupportedException extends Exception {

		private static final long serialVersionUID = 1L;

		public HttpVersionNotSupportedException() {
			super("Http Version Not Supported");
		}
		
		public HttpVersionNotSupportedException (String errMsg){
			super(errMsg);
		}
		
		public int get_errCode(){
			return 400;
		}
}
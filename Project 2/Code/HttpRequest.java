
/**
 * Data structure to store relevant informations about a client request
 * @author Olivier Moitroux & Thomas Vieslet
 *
 */
class HttpRequest {
	
	private String methodType;
	private String url; 
	private String version;
	private String[] headers;
	private String content;
	private String cookie;
	
	public HttpRequest(String methodType, String url, String version, String[] headers, String cookie) {
		this.methodType = methodType;
		this.url = url;
		this.version = version;
		this.headers = headers;
		this.cookie = cookie;
		this.content = null;
	}
	
	public HttpRequest(String methodType, String url, String version, String[] headers, String content, String cookie) {
		this(methodType, url, version, headers, cookie);
		this.content = content;
	}
	
	public String get_methodType(){return methodType;}
	public String get_url(){return url;}
	public String get_version(){return version;}
	public String[] get_headers(){return headers;}
	public String get_content(){return content;}
	public String get_cookie(){return cookie;}
	public boolean cookie_is_set(){return cookie != null;}
}

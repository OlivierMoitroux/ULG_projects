import java.io.*;
import java.net.*;
import java.util.Date;

/**
 * Expose a set of methods to deal with the http protocol
 * @author Olivier Moitroux & Thomas Vieslet
 *
 */
public class HttpManager {

	protected BufferedReader reader;
	protected PrintWriter writer;

	protected static final String HTTP_VERSION = WebServer.HTTP_VERSION;

	public HttpManager(Socket sock) throws IOException {
		reader = new BufferedReader(new InputStreamReader(sock.getInputStream()));
		writer = new PrintWriter(sock.getOutputStream());
	}

	/**
	 * <code>receive()</code>
	 * @return an httpRequest data structure filled with useful inform. about the user request
	 * @throws IOException
	 * @throws HttpVersionNotSupportedException
	 * @throws LengthRequiredException
	 * @throws BadRequestException
	 * @throws MethodNotAllowedException
	 */
	public HttpRequest receive() throws IOException, HttpVersionNotSupportedException, LengthRequiredException, BadRequestException, MethodNotAllowedException {
		try {
			
			// ex: GET /play.html HTTP/1.1 200 OK
			String buf = reader.readLine();
			String[] firstLine = buf.split(" ");

			String method = firstLine[0];
			String url = firstLine[1];
			String httpVersion = firstLine[2];


			if(!httpVersion.equals(WebServer.HTTP_VERSION)){
				System.out.println("[httpManager] httpversion not supported");
				throw new HttpVersionNotSupportedException();
			}

			url = URLDecoder.decode(url, "UTF-8");
			String cookie = null;

			/* GET */
			if(method.equals("GET")) {
				
				do {
					buf = reader.readLine();
					System.out.println(buf);
					
					if(buf.startsWith("Cookie:")) {
						cookie = buf.substring(buf.indexOf("=") + 1, buf.length()); // 16
						System.out.println("cookie detected:" + cookie);
					}
					
				} while(!buf.isEmpty());
				
				if(cookie == null){
					System.out.println("[httpManager] detect cookie not set");
				}
				return new HttpRequest(method, url, httpVersion, null, cookie);
			}
			
			/* POST */
			else if (method.equals("POST")){

				// parse the headers, retrieve content length
				int contentLength = -1;
				do {
					buf = reader.readLine();
					if(buf.startsWith("Content-Length:")) {
						contentLength = Integer.valueOf(buf.substring(16, buf.length()));
						System.out.println("Content-Length detected:" + contentLength);
					}
					if(buf.startsWith("Cookie:")) {
						cookie = buf.substring(16, buf.length());
						System.out.println("Cookie detected: " + cookie);
					}
				} while(!buf.isEmpty());

				if(contentLength < 0)
					throw new LengthRequiredException();

				char[] content = new char[contentLength];
				reader.read(content, 0, contentLength);

				return new HttpRequest(method, url, httpVersion, null, String.valueOf(content), cookie);
			}
			else{
				throw new MethodNotAllowedException();
			}
		}
		catch(NullPointerException | IndexOutOfBoundsException e) {
			throw new BadRequestException("Invalid status line");
		}
	}

	/**
	 * <code>send(String[] content, String contentType)</code>
	 * @param content
	 * @param contentType
	 */
	public void send(String[] content, String contentType) {
		send(200, "OK", null, content, contentType);
	}

	/**
	 * <code>redirect (String page)</code></br>
	 * Send a redirection message to <code>page</code>
	 * @param page
	 */
	public void redirect (String page) {
		send(303, "See other", new String[] {"Location: http://localhost:" + WebServer.PORT_NO +
				page}, null, "text/html");
	}

	/**
	 * <code>send_first_page(String cookie, String[] webPage)</code><br>
	 * Send a message to the user's web browser to set a cookie, as well as the page to display
	 * @param newCookie
	 */
	public void set_cookie_for_user(String cookie, String[] webPage) {
		String[] header = {"Set-Cookie: SESSID=" + cookie + "; path=/"};
 		send(200, "OK", header, webPage, "text/html");
	}

	/**
	 * <code>send_err(int errCode)</code><br>
	 * Send an error message
	 * @param errCode
	 */
	public void send_err(int errCode) {//throws ServerException{
		String msg = null;
		switch(errCode){
			case 400: msg = new String("Bad Request"); break;
			case 404: msg = new String("Page Not Found"); break;
			case 405: msg = new String("Method Not Allowed"); break;
			case 411: msg = new String("Length Required"); break;
			case 505: msg = new String("HTTP Version Not Supported"); break;
			case 501: msg = new String("Method Not Implemented"); break;
			default: ;
		}
		send(errCode, msg, null, null, null);
	}

	/**
	 * <code>send(int retCode, String retStatus, String[] headers, String[] content, String contentType)</code><br>
	 * Main send() method to send (chunck encoding) any http messages. 
	 * @param retCode
	 * @param retStatus
	 * @param headers
	 * @param content
	 * @param contentType
	 */
	protected void send(int retCode, String retStatus, String[] headers, String[] content, String contentType) {
		
        try{
        	
			writer.print(HTTP_VERSION + " " + retCode + " " + retStatus + "\r\n");
			writer.print("Date: " + new Date() + "\r\n");
			writer.print("Content-Type: "+ contentType + "\r\n");
            writer.print("Transfer-Encoding: chunked\r\n");
            
			if(headers != null) {
				for(int i = 0; i < headers.length; i++)
					writer.println(headers[i] + "\r\n");
			}
			
			if (content != null) {
	            for(int i = 0; i < content.length && content[i] != null; i ++) {
	            	
	            	if(content[i].length() == 0)
	            		continue;
	                writer.print("\r\n" + Integer.toHexString(content[i].length()) +"\r\n");
	                writer.print(content[i]);
	                writer.flush();
	            }	            
	            
	            writer.print("0");
	            writer.flush();
			}
			writer.print("\r\n");
			writer.print("\r\n");
			writer.flush();

        }
        catch(Exception e){ System.out.println("Error in parsing reply"); System.err.println(e.getMessage()); }
	}
	
	/**
	 * <code>sendStaticPage(String[] cleanPage, Mastermind game)</code><br>
	 * Send a static page for clients that don't have JS enabled. Colors are filled in the history area
	 * @param cleanPage
	 * @param game
	 */
	public void sendStaticPage(String[] cleanPage, Mastermind game) {
		
		writer.print(HTTP_VERSION + " 200 OK" + "\r\n");
		writer.print("Date: " + new Date() + "\r\n");

		writer.print("Content-Type: text/html\r\n");
		writer.print("Transfer-Encoding: chunked\r\n");
	    
		String line;
		
		for(int i = 0; i < cleanPage.length && cleanPage[i] != null; i ++){
			
			if(cleanPage[i].length() == 0)
        		continue;
			try {
				// Change the style of the bubble with the history data
				line = fill_bubbles(cleanPage[i], game);
				
				writer.print("\r\n" + Integer.toHexString(line.length()) +"\r\n");
				writer.print(line);
				writer.flush();
			}
			catch(Exception e){
				System.err.println("Fill bubbles failed");
				// System.exit(-1);
			}
        }	               
		writer.print("0");
		writer.print("\r\n");
		writer.print("\r\n");
		writer.flush();
	}

	/**
	 * <code>fill_bubbles(String line, Mastermind game)</code><br>
	 * If the line needs to be changed, changes the style of the bubbles according to the history
	 * @param line
	 * @param game
	 * @return
	 */
    protected String fill_bubbles(String line, Mastermind game){
    	
		String[][] history = game.get_clrPropHistory();
		String[][] flags = game.get_flagsHistory();
		
		
		final String bigBubble = new String("id= \"bigBubble");
		final String smallBubble = new String("id= \"smallBubble");
		
		// To detect after how many bytes, we get the relevant information to target the right bubble
		final int smallBubbleLen = smallBubble.length();
		final int bigBubbleLen = bigBubble.length();
		
		int bIndex = line.indexOf(bigBubble);
		int sIndex = line.indexOf(smallBubble);
		
		if(bIndex == -1 && sIndex == -1){
			return line;
		}
		
		if(bIndex != -1) {		
			int col = Integer.parseInt(line.substring(bIndex+bigBubbleLen, bIndex+bigBubbleLen + 1));
			String tmp = line.substring(bIndex+bigBubbleLen+2, bIndex+bigBubbleLen+4);
			
			int turnNo = tmp.substring(1, 2).equals("\"") ? Integer.parseInt(tmp.substring(0,1)) : Integer.parseInt(tmp);
			
			if(history[12-turnNo][col-1] == null) 
				return line;
			return "<div id=\"bigBubble\"" + col + "-" + turnNo + " class=\"bigBubble\" style=\"background-color:" + history[12-turnNo][col-1] + "\">" ;
		}
		else{
			int col = Integer.parseInt(line.substring(sIndex+smallBubbleLen, sIndex+smallBubbleLen + 1));
			String tmp = line.substring(sIndex+smallBubbleLen+2, sIndex+smallBubbleLen+4);
			int turnNo = tmp.substring(1, 2).equals("\"") ? Integer.parseInt(tmp.substring(0,1)) : Integer.parseInt(tmp);
			
			if(flags[12-turnNo][col-1] == null) 
				return line;
			return "<div id=\"smallBubble\"" + col + "-" + turnNo + " class=\"smallBubble\" style=\"background-color:" + flags[12-turnNo][col-1]+"\" >" ;
			}
		
	}
}

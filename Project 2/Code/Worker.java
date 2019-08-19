
import java.io.*;
import java.net.*;
import java.util.*;
import java.util.Map.Entry;

/**
 * Deal with one request from the user (receive+reply)
 * @author Olivier Moitroux & Thomas Vieslet
 *
 */
public class Worker implements Runnable {
	
	// Data structure to store <cookies,game>
	protected static HashMap<String, Mastermind> pendingGames = new HashMap<String, Mastermind>();
	
	protected Socket sock;
	protected final Thread worker;
	
	// Class to handle all the HTTP requests
	protected HttpManager httpManager;
	
	// The party associated to the client
	protected Mastermind game;

	public Worker(Socket socket) {

		worker = new Thread(this, "");
		sock = socket;
	}

	public void start() {
		worker.start();
	}

	@Override
	public void run() {

		// Colors input by user
		String[] colors = new String[Mastermind.CLR_2_GUESS];
		// Cookie of the user
		String cookie = null;
		// To detect if client wants to load the page or make a clr request
		Boolean noQuery = true;

		try {
			
			httpManager = new HttpManager(sock);

			// Get the request data
			HttpRequest request = httpManager.receive();
			
			// Request to root page
			if (request.get_url().equals("/")) {
				// Redirection
				System.out.println("[Worker] Redirection done");
				httpManager.redirect("/play.html");
				close_connection();
				return;
			}

			else if (!request.get_url().startsWith("/play")) {
				System.out.println("[Worker] "+ request.get_url()+" : Page not found");
				// Page not found
				httpManager.send_err(404);
				close_connection();
				sock.close();
				return;
				
			}
			
			// If the client has already a cookie
			if (request.cookie_is_set()) {
				
				cookie = new String(request.get_cookie());
				
				try {game = retrieve_game_pending(cookie);}
				catch (MastermindException e) {
					game = new Mastermind();
					System.out.println("[Worker] New game built");
				}
			} 
			else {
				System.out.println("[Worker] Asks to create a cookie");
				cookie = new_cookie();
				
				// Ask the web browser of the user to set a cookie
				httpManager.set_cookie_for_user(cookie, get_page_array());
				game = new Mastermind();
				System.out.println("[Worker] New game built");
				close_connection();
				return;
			}

			switch (request.get_methodType()) {

			case "GET":
				
				noQuery = get_user_submit(request, colors);

				// No specific query -> send the web page
				if (noQuery == true)
					httpManager.send(get_page_array(), "text/html");
			
				// Handle the AJAX request
				else if (noQuery == false) {
					
					// display correct clrs for convenience
					game.display_secretClrs();

					String[] flags;
					try { flags = game.compute_flags(colors); game.inc_turnNo();}
					catch (MastermindException e) { throw new BadRequestException(); }
					String[] contentArray = {"Flags:" + flags[0] + "-" + flags[1]};
                    httpManager.send(contentArray, "application/json");
				}

				else {
					httpManager.send_err(new BadRequestException().get_errCode());
				}
				break;

			case "POST":
				
				noQuery = get_user_submit(request, colors);

				if(noQuery == false){
					String[] flags;
					try { 
						flags = game.compute_flags(colors); 
						game.save2History(colors, flags);
						game.display_secretClrs();
					}
					catch (MastermindException e) { throw new BadRequestException(); }
					
					// When JS disabled, send a static page with the history area already filled
					httpManager.sendStaticPage(get_page_array(), game);
					
				}
				else {
					throw new BadRequestException("Bad request");
				}
				break;
			default:
				// Method Not implemented
				httpManager.send_err(501);
				break;

			}
		} catch (BadRequestException e) {
			httpManager.send_err(e.get_errCode());
		} catch (HttpVersionNotSupportedException e) {
			httpManager.send_err(e.get_errCode());
		}
		
		catch (LengthRequiredException e) {
			httpManager.send_err(e.get_errCode());
		} catch (MethodNotAllowedException e) {
			httpManager.send_err(e.get_errCode());
		} catch (IOException e) {
			System.err.println(e.getMessage());
		}

		// After one request, we release the thread
		finally {
			close_connection();
			if (cookie != null) {
				System.out.println("[Worker] Save pending game");
				if(game.is_lost() || game.is_won())
					pendingGames.remove(cookie);
				else
					save_pendingGame(cookie, game);
			}
		}

	}

	/**
	 * <code>get_user_submit(HttpRequest request, String[] colors)</code><br>
	 * Fill the array <code>colors</code> with the data stored in the request or return true if no query detected 
	 * @param request
	 * @param colors
	 * @return true if there was no request, false otherwise
	 * @throws BadRequestException
	 */
	protected Boolean get_user_submit(HttpRequest request, String[] colors) throws BadRequestException {
		
		String paramsLine = null;
		String[] urlFields;
		String query ="";

		if (request.get_content() != null) {
			// Content because that was a POST()
			paramsLine = request.get_content();
		}
		else{
			try {
				urlFields = request.get_url().split("\\?");// Otherwise, Dangling meta character '?' near index 0
				paramsLine = urlFields[1];
			}
			catch(Exception e){
				// Simple GET /play.html
				System.out.println(e.getMessage());
				return true; // noQuery
			}
		}
		try {

			String listOfParam = new String(paramsLine);
			for (String param : listOfParam.split("&")){
				System.out.println(param);
				String[] fields = param.split("=");
				switch (fields[0]) {
					case "submitClr1":
						colors[0] = fields[1];
						break;
					case "submitClr2":
						colors[1] = fields[1];
						break;
					case "submitClr3":
						colors[2] = fields[1];
						break;
					case "submitClr4":
						colors[3] = fields[1];
						break;
					case "query":
						query = fields[1];

						break;
					default:
						throw new BadRequestException("Bad request");
					}
				}

		} catch (ArrayIndexOutOfBoundsException e) {
			System.out.println("[Worker] Error while parsing parameters");
			System.err.println(e.getMessage());
			throw new BadRequestException("No content nor parameter in url");
		}
		if(query.equals("")){
			return true;
		}
		if (!query.equals("update") && !query.equals("Envoyer")){
			throw new BadRequestException("Query unknown");
		}
		return false;
	}

	/**
	 * <code>new_cookie()</code><br>
	 * Generate a new, random and unique cookie
	 * @return cookie
	 */
	protected synchronized String new_cookie() {

		boolean alreadyExists = false;
		String cookie;
		do {
			cookie = UUID.randomUUID().toString();
			cookie = cookie.replace("-", "");
			// Check if unique in the map
			Iterator<Entry<String, Mastermind>> it = pendingGames.entrySet().iterator();
			while (it.hasNext()) {
				Map.Entry<String, Mastermind> pair = it.next();
				if (cookie.equals(pair.getKey()))
					alreadyExists = true;
			}
		} while (alreadyExists);
		System.out.println("[Worker] created a cookie:[" + cookie + "]");
		return cookie;
	}

	/**
	 * <code>retrieve_game_pending(String cookie)</code>
	 * @param cookie - the key to access the map
	 * @return a game party pending or null no party pending
	 * @throws MastermindException
	 */
	protected synchronized Mastermind retrieve_game_pending(String cookie) throws MastermindException {
		try {
			System.out.println("[Worker] Current size of the map:" + pendingGames.size());
			Iterator<Entry<String, Mastermind>> it = pendingGames.entrySet().iterator();
			while (it.hasNext()) {
				Map.Entry<String, Mastermind> pair = it.next();
				
				// Clean the data structure by the way
				if(pair.getValue().time_elapsed() > WebServer.COOKIE_LIFE_TIME){	
					pendingGames.remove(pair.getKey());
					continue;
				}
				
				if (cookie.equals(pair.getKey())) {
					System.out.println("[Worker] Found a game pending");
					return (Mastermind) pair.getValue();
				}
			}
			throw new MastermindException("No pending game");
		} catch (Exception e) {
			throw new MastermindException("No pending game via null pointer");
		}
	}

	/**
	 * <code>save_pendingGame(String cookie, Mastermind game)</code>
	 * @param cookie
	 * @param game
	 */
	protected synchronized void save_pendingGame(String cookie, Mastermind game) {
		pendingGames.put(cookie, game);
	}
	
	
	/**
	 * <code>get_page_array()</code>
	 * @return the web page segmented in lines in a string array
	 */
	protected String[] get_page_array() {
		int nbLines = 0;
		FileReader fr = null;
		String[] webPage = null;
		BufferedReader br = null;
		
		// Get the number of lines in play.html
		try{
			fr = new FileReader("play.html");
			LineNumberReader count = new LineNumberReader(fr);
			while (count.skip(Long.MAX_VALUE) > 0){} // Prevent going above the limit of long
		   nbLines = count.getLineNumber() + 1; // line index starts at 0 -> +1
		   count.close();
		}
		catch(Exception e){
			return null;
		}
		
		
		try {
			webPage = new String[nbLines];
			fr = new FileReader("play.html");
			br = new BufferedReader(fr);
			String line;

			for(int i = 0; (line = br.readLine()) != null; i++) {
			    webPage[i] = new String(line + System.lineSeparator());
			}
		}catch (IOException e) {System.err.println("read failed"); System.err.println(e.getMessage()); }

		finally{
			try { br.close(); fr.close();}
			catch (IOException e) { System.err.println("Finally failed");e.printStackTrace(); }
		}
		return webPage;
	}


	/**
	 * <code>Close_connection</code>
	 * <br>Close the socket
	 */
	protected void close_connection() {
		try{ sock.close(); }
		catch(IOException e){
			System.err.println("[Worker] Can't close connection: " + e.getMessage());
		}
	}

}

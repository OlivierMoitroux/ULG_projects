
import java.io.*;
import java.net.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * The <code> WebServer </code> class:
 * <ul><li> Waits for TCP connection on a given port
 * <li> Receives requests through that connection 
 * <li> When established, potentially updates its internal state accordingly
 * 
 * @author Olivier Moitroux & Thomas Vieslet : Group15
 * @version 1
 * @see MastermindClient
 */
public class WebServer {
	
	public static final int COOKIE_LIFE_TIME = 10 * 60; // 10 minutes
	public static final int PORT_NO = 8015;
	
	private static int maxThreads = 1; // Default value 
	public static final String HTTP_VERSION = "HTTP/1.1";
	
	public WebServer() {}
	
	public static void main(String[] args) {
		
		ServerSocket ss = null;
		ExecutorService threadPool = null;
		try { 
			ss = new ServerSocket(PORT_NO); 
			if(args[0] != null) {
				maxThreads = new Integer(args[0]);
			}
			threadPool = Executors.newFixedThreadPool(maxThreads);
			
		}
		catch (IOException e) {
			System.err.println("Error while building socket - could not listen on port " + PORT_NO);
			e.printStackTrace();
			System.exit(-1);
			return;
		}
		catch (NumberFormatException e) {
			System.err.println("Correct usage: java WebServer <maxThreads>\nmaxThreads should be a number");
			System.exit(-1);
		}
		catch (IllegalArgumentException e) {
			System.err.println("Usage: java WebServer <maxThreads>\nmaxThreads should be positive");
			System.exit(-1);
		}
		catch(IndexOutOfBoundsException e){
			System.exit(-1);
		}
		
		System.out.println("Server launched");
		
		try{
			while(true) {
				
					/* wait for clients */
					Socket client = ss.accept();
					
					/* build a thread to deal with one and only one client request */
					threadPool.execute(new Worker(client));
					
					System.out.println("[MasterMindServer] new client: " + client.getRemoteSocketAddress());
			}

		} 
		catch (IOException e) {
			System.err.println("Accept failed on port " + PORT_NO);
			e.printStackTrace();
		}
		
		finally {
			try { ss.close(); } 
			catch (IOException e) {
				System.err.println(e.getMessage());
				System.exit(-1);
			}
		}
	}
}
	
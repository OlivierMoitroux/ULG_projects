package be.ac.ulg.montefiore.oop;
import java.io.*;
import java.lang.String;
// Import des constantes de jeu
import static be.ac.ulg.montefiore.oop.graphics.MinesweeperView.*;

public class MSFileReader {
	
	private int width 		= 0;
	private int height 		= 0;
	private int nbreMines 	= 0;
	private int difficulty	= 0;
	private int[][]  minesData;
	String fileName;
	
	private InputStreamReader fr;
	private BufferedReader br;
	private FileInputStream fis;
	
	// Constructeur
	public MSFileReader(String fileName){
		this.fileName = fileName;
	}
	
	// Il est théoriquement préférable de mettre les variables privates :
	// (même si le fait qu' elles soient publiques dans cette classe me semblait avantageux)
	public int getHeight(){return height;}
	public int getWidth(){return width;}
	public int getNbreMines(){return nbreMines;}
	public int[][] getMines(){return minesData;}
	public int getDifficulty(){return difficulty;}
	
	/* ------------------------------------------------------------------------- *
	 * Vérifie que les coordonnées des mines sont bien différentes. Renvoit vrai si
	 * c'est le cas.
	 * ------------------------------------------------------------------------- */
	private boolean minesDifferent() {
		for(int i = 0; i < nbreMines-1; i++){
			for(int cursor = i+1; cursor < nbreMines; cursor++){
				if((minesData[i][0] == minesData[cursor][0])&&(minesData[i][1] == minesData[cursor][1])){
					return false;
				}
			}
		}
		return true;
	}
	
	/* ------------------------------------------------------------------------- *
	 * Effectue les opérations nécessaires en fin de lecture d'un fichier
	 * ------------------------------------------------------------------------- */
	private void close(){
		try{
			if(br != null) br.close();
			if(fr != null) br.close();
			if(fis != null) br.close();
		}
		catch (IOException e){ } // on ignore
		finally{
			br = null;
			fr = null;
			fis = null;
		}
	}
	
	/* ------------------------------------------------------------------------- *
	 * Ouvre, lit et récolte l'information présente dans le fichier dont le nom
	 * est spécifié lors de l'instance de la classe (constructeur).
	 * ------------------------------------------------------------------------- */
	public void openFile() throws MSException { 
		
		try {
		    fis = new FileInputStream (fileName);
		    fr = new InputStreamReader (fis);
		    br = new BufferedReader (fr);			
		    
		    String line = br.readLine();
		        
		    // On regarde la première ligne pour connaître la difficulté
		    switch (line){
		    	case "easy" : 
		    		difficulty = EASY;
		    		width = EASY_WIDTH; height = EASY_HEIGHT; nbreMines = EASY_MINES;
		    		break;
		        		
		    	case "medium" :
		    		difficulty = MEDIUM;
		    		width = MEDIUM_WIDTH; height = MEDIUM_HEIGHT; nbreMines = MEDIUM_MINES;
		        	break;
		        		
		        case "hard" :
		        	difficulty = HARD;
		        	width = HARD_WIDTH; height = HARD_HEIGHT; nbreMines = HARD_MINES;
		        	break;
		        		
		        default : 
		        	throw new MSException ("Difficulty is wrongly formatted in " + fileName);
		        	
		    }		        
		    // On regarde le reste
		   
		    minesData = new int[nbreMines][2];
		    String[] coord;
		    int cursor = 0;
		    
		    for (line = br.readLine() ; line != null; line = br.readLine(), cursor++) {
		    	
		    	// Sépare la chaîne à chaque ",". Cfr. javadoc pour plus d'infos
		    	coord = line.split("," , 2);
		    	
		    	minesData[cursor][0] = Integer.parseInt(coord[0]);
		    	minesData[cursor][1] = Integer.parseInt(coord[1]);

		    }
		    if(!minesDifferent()){
	    		throw new MSException("Error : file must countain " + nbreMines + " different mines coordinates");
	    	}
		    if(cursor < nbreMines - 1){
		    	throw new MSException("Error : file in " + difficulty + " mode should have " + nbreMines + " mines");
		    }
		    
		} catch (FileNotFoundException e) { // by FileInputStream
			System.err.println ("File " + fileName +" not found");
			e.printStackTrace();
			
		} catch(IOException e) { // by FileInputStream
			System.err.println("Can't open or read file "+ fileName ); //+ exception.get(message));
			e.printStackTrace();
			
		} catch(ArrayIndexOutOfBoundsException e){ // Le buffer est allé plus loin que le nombre de mines toléré pour la difficulté
			System.err.println("More mines coordinates than allowed for the difficulty in " + fileName); //+ exception.get(message));
			e.printStackTrace();
			
		} catch(SecurityException e){ // by BufferedReader
			System.err.println(" More mines coordinates than allowed for the difficulty"); //+ exception.get(message));
			e.printStackTrace();
		}
		
		finally{this.close();}	

	}
	
}		


		    	

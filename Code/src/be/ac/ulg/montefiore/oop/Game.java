package be.ac.ulg.montefiore.oop;
import be.ac.ulg.montefiore.oop.graphics.*;

public class Game {

	private MyMSEventsHandler 	handler;
	private MinesweeperSwingView 	msv;
	
	/* ------------------------------------------------------------------------- *
	 * Classe qui gère les aspects fondamentaux (logique & GUI) d'un Minesweeper.
	 *  Est capable de lancer une nouvelle partie, de mettre à jour les infos de
	 *  la partie en cours ou encore de notifier l'arrêt d'une partie et de
	 *  terminer une  partie.
	 * ------------------------------------------------------------------------- */
	public Game(){ 
		
	}
	/* ------------------------------------------------------------------------- *
	 * Méthode qui lance un nouveau jeu grâce au fichier dont le nom est 
	 * fourni lors de l'instance
	 * IN : le nom du fichier
	 * ------------------------------------------------------------------------- */
	public void startNewGame(String fileName) throws MSException{
		try{
			MSFileReader fileGame = new MSFileReader(fileName);
			fileGame.openFile();
			handler = new MyMSEventsHandler(
					fileGame.getWidth(),
					fileGame.getHeight(),
					fileGame.getNbreMines(),
					fileGame.getMines()
					);
			
			msv = new MinesweeperSwingView(fileGame.getDifficulty(), handler);
			
			msv.updateGrid(handler.getGrid());
			msv.updateFlagsNumber(0);
			
			msv.refreshWindow();

		} catch (BadDifficultyException e) {
			System.err.println("Bad difficulty while creating object");
			e.printStackTrace();
		} catch (NullHandlerException e) {
			System.err.println("Handler given while creating object is not valid");
			e.printStackTrace();
		} catch (NullArrayException e) {
			System.err.println("GUI grid update : trying de dereference a Null array");
			e.printStackTrace();
		} catch (BadHeightException e) {
			System.err.println("GUI grid update : error grid dimension (height)");
			e.printStackTrace();
		} catch (BadWidthException e) {
			System.err.println("GUI grid update : error grid dimension (width)");
			e.printStackTrace();
		} catch (BadTileConstantException e) {
			System.err.println("GUI grid update : tile constant mismatch or unknown");
			e.printStackTrace();
		}
		
	}
	
	/* ------------------------------------------------------------------------- *
	 * Met à jour les informations de jeu (logique & GUI)
	 * ------------------------------------------------------------------------- */
	public void playGame() throws MSException{
		try{
			
			msv.updateFlagsNumber(handler.getNbreFlagged());
			msv.updateGrid(handler.getGrid());
			
			msv.refreshWindow();
		
		} catch (NullArrayException e) {
			System.err.println("GUI grid update : trying de dereference a Null array");
			e.printStackTrace();
		} catch (BadHeightException e) {
			System.err.println("GUI grid update : error grid dimension (height)");
			e.printStackTrace();
		} catch (BadWidthException e) {
			System.err.println("GUI grid update : error grid dimension (width)");
			e.printStackTrace();
		} catch (BadTileConstantException e) {
			System.err.println("GUI grid update : tile constant mismatch or unknown");
			e.printStackTrace();
		}
		
	}
	
	/* ------------------------------------------------------------------------- *
	 * Gère la fin du jeu (affichage du message win/lost)
	 * ------------------------------------------------------------------------- */
	
	public void endGame() throws MSException{
		if(handler.isWon()){
			playGame();  msv.win();
		}
		else{
			playGame(); msv.lose();
		}
		
	}
	
	/* ------------------------------------------------------------------------- *
	 * Renvoit vrai si le joueur a gagné ou perdu
	 * ------------------------------------------------------------------------- */
	public boolean gameEnded(){ return handler.isLost() || handler.isWon(); }
}

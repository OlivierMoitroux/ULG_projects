package be.ac.ulg.montefiore.oop;

public class Minesweeper {
	
	/* ------------------------------------------------------------------------- *
	 * Gère les étapes fondamentales d'un démineur et lancera une partie sur base
	 *  d'un fichier de coordonnées de mines.
	 * ------------------------------------------------------------------------- */
	public static void main(String[] args) throws MSException{ 
		try{
			if(args.length != 2){
				System.out.print("2 arguments expected : \n "
						+ "'load' + 'folderName_containing_minesCoord.txt' \n");
				throw new MSException("number of argument not expected");
			}
			if ("load".equals(args[0])){
				
				Game Minesweeper = new Game();
				
				Minesweeper.startNewGame(args[1]);
			
				while(!Minesweeper.gameEnded()){
					Minesweeper.playGame();
					// Attente de 250 ms avant l'itération suivante pour limiter
					// l'exploitation du processeur
					Thread.sleep(250);
				}
				Minesweeper.endGame();
			}
			// NB : cette construction est un peu bizarre mais provient du fait que
			// je n'avais pas cerné le déclenchement automatique et l'autonomie du left click.
			
		} catch (InterruptedException e) {
			System.err.println("Minesweeper : thread temporisation error");
			e.printStackTrace();
		}
	}
}
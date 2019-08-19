package be.ac.ulg.montefiore.oop;
import be.ac.ulg.montefiore.oop.graphics.MinesweeperEventsHandler;
// Import des constantes pour la GUI
import static be.ac.ulg.montefiore.oop.graphics.MinesweeperView.*;
// Import des constantes pour la logique
import static be.ac.ulg.montefiore.oop.Tile.*;

public class MyMSEventsHandler implements MinesweeperEventsHandler {
	private Grid grid;
	private Tile[][] tileGrid;
	private int[][] GUIgrid;
	
	// Constructeur
	public MyMSEventsHandler(int width, int height, int nbreMines, int [][] minesData) throws MSException{
		
		grid = new Grid(width, height, nbreMines);
		tileGrid = grid.createGridLayout(minesData);
		GUIgrid = new int[height][width];
		for(int i =0; i < height; i++){
			for (int j = 0; j < width; j++){
				GUIgrid[i][j] = TILE_HIDDEN;
			}
		}
	}
	

	/* ------------------------------------------------------------------------- *
	 * Convertit une grille dont les cases sont de type "Tile" (pour la logique)
	 * en une grille compatible avec la GUI (type int)
	 * ------------------------------------------------------------------------- */
	private void convertGrid(final int x, final int y, boolean lost){
		
		if(tileGrid[y][x].getType() == NUM_TILE)
			GUIgrid[y][x] = tileGrid[y][x].toView(false, false);
		else {
			tileGrid = grid.getGridLayout();
			for (int i = 0; i < grid.getHeight(); i++){
				for(int j = 0; j < grid.getWidth(); j++){
					// conversion
					GUIgrid[i][j] = tileGrid[i][j].toView(false, lost);
				}
			}
			if(lost) // Pour la mine exploded si perdu
				GUIgrid[y][x] = tileGrid[y][x].toView(true, lost);
		}

	}
	
	/* ------------------------------------------------------------------------- *
	 * Renvoit le nombre de cases avec un drapeaux associé dans la grille
	 * ------------------------------------------------------------------------- */
	public int getNbreFlagged(){return grid.getNbreFlagged();}
	
	/* ------------------------------------------------------------------------- *
	 * Vrai si gagné
	 * ------------------------------------------------------------------------- */
	public boolean isWon(){return  grid.isWon();}
	
	
	/* ------------------------------------------------------------------------- *
	 * Vrai si perdu
	 * ------------------------------------------------------------------------- */
	public boolean isLost(){return grid.isLost();}
	
	/* ------------------------------------------------------------------------- *
	 * Renvoit la grille convertie (à chaque click) pour la GUI
	 * ------------------------------------------------------------------------- */
	public int[][] getGrid(){return GUIgrid;}
	
	@Override
	public void leftClickTile(final int x, final int y) {
		
		tileGrid = grid.getGridLayout();
		// On ne peut révéler que si la case est cachée et qu'il ne s'agit pas d'un drapeau
		if(tileGrid[y][x].isRevealed() == false && !tileGrid[y][x].isFlagged()){
			grid.revealTile(y, x);
			convertGrid(x, y, grid.isLost());
		}
	}

	@Override
	public void rightClickTile(final int x, final int y) {
		grid.flagClick(x, y);
		convertGrid(x, y, grid.isLost()); // bof car à chaque fois on le fait ...
		
	}

	@Override
	public String getStudentName() {return "Olivier Moitroux";}

}

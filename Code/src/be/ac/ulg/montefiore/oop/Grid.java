package be.ac.ulg.montefiore.oop;
import static be.ac.ulg.montefiore.oop.Tile.*;

/* ------------------------------------------------------------------------- *
 * Classe ayant pour tâches de gérer une grille
 * ------------------------------------------------------------------------- */
public class Grid {
	
	private int width, height;
	
	// Au cas où l'on décide que l'on peut mettre +/- de drapeaux que de bombes
	private int nbreFlag; // (Pas strictement nécessaire si les règles ne changent pas)
	private int nbreFlagged;
	private int nbreMines;
	private int nbreTiles; // (On pourrait s'en passer dans l'absolu)
	private int nbreTilesRevealed;
	
	private boolean lost;
	
	private Tile[][] gridLayout;
	
	// Constructor
	public Grid(int width, int height, int nbreMines){
		this.width 				= width;
		this.height 			= height;
		this.nbreMines 			= nbreMines;
		this.nbreFlag 			= nbreMines;
		this.nbreTiles			= width*height;
		this.nbreFlagged 		= 0;
		this.nbreTilesRevealed 	= 0;
		gridLayout				= new Tile[height][width];
		lost = false;
	}
	
	/* ------------------------------------------------------------------------- *
	 * Place les mines dans la grille grâce à un vecteur d'entier contenant des mines
	 * ------------------------------------------------------------------------- */
	private void fillMines(int[][] minesPos) throws MSException {
		try{
			for (int i = 0; i< nbreMines; i++){	
				gridLayout[minesPos[i][1]][minesPos[i][0]].setType(MINE_TILE);
				// /!\ passage au ref matriciel
			}
		} catch(IndexOutOfBoundsException e){
			System.err.println("Error while filling mines in the grid : index exceed dimensions");
			
		}
	}
	
	/* ------------------------------------------------------------------------- *
	 * Place les cases numérotées en fonction des mines présentes dans la grille
	 * ------------------------------------------------------------------------- */
	private void fillNumbers() throws MSException{
		
		int count = 0; // Number of mines in the neighborhood
		
		for (int i = 0; i < height; i++){
			for(int j = 0; j < width; j++, count = 0){
				
				// Conditions pour pouvoir rester dans les limites de la grille
				boolean left = (j-1) >= 0;
				boolean right = (j+1) < width;
				boolean up = (i-1) >= 0;
				boolean down = (i+1) < height;
				
				if(gridLayout[i][j].getType() != MINE_TILE){
					if(up){
						// up
						if (gridLayout[i-1][j].getType() == MINE_TILE)
							count++;
						
						// upleft
						if (left){
							if (gridLayout[i-1][j-1].getType() == MINE_TILE)
								count++;
						}
						// up right
						if (right){
							if (gridLayout[i-1][j+1].getType() == MINE_TILE)
								count++;
						}
					}
					if(down){
						// Down
						if (gridLayout[i+1][j].getType() == MINE_TILE)
							count++;
						
						// downleft
						if (left){
							if (gridLayout[i+1][j-1].getType() == MINE_TILE)
								count++;
						}
						// downright
						if (right){
							if (gridLayout[i+1][j+1].getType() == MINE_TILE)
								count++;
						}
					}
					
					if(left){
						// left
						if (gridLayout[i][j-1].getType() == MINE_TILE)
							count++;
					}
					
					if(right){
						// right
						if (gridLayout[i][j+1].getType() == MINE_TILE)
							count++;
					}
					
					if (count > 0)
						gridLayout[i][j].setNumTile(count);
				}
				
			} // fin for j
		} // fin for i
	} // fin méthode fillNumbers()
	
	/* ------------------------------------------------------------------------- *
	 * Révèle les cases vides / mines / numérotées
	 * ------------------------------------------------------------------------- */
	public void revealTile(int i , int j){
		// Dans le démineur de windows (<10), les drapeaux ne sont pas
		// révélés en cas de floodfill
		if(gridLayout[i][j].isFlagged())
			return;

		gridLayout[i][j].reveal(); nbreTilesRevealed ++; // Tile gère les flags toute seule
		
		if (gridLayout[i][j].getType() == MINE_TILE)
			lost = true;
		
		else if (gridLayout[i][j].getType() == EMPTY_TILE){
			
			// Conditions pour pouvoir rester dans les limites de la grille
			boolean left = j > 0;
			boolean right = j < width-1;
			boolean up = i > 0;
			boolean down = i < height-1;
			
				if(up ){
					if(!gridLayout[i-1][j].isRevealed()){
					// up
					revealTile(i-1,j);
				}
					// upleft
					if (left && !gridLayout[i-1][j-1].isRevealed() && gridLayout[i-1][j-1].getType() == NUM_TILE)
						revealTile(i-1, j-1);
					
					// upright
					if (right && !gridLayout[i-1][j+1].isRevealed() && gridLayout[i-1][j+1].getType() == NUM_TILE)
						revealTile(i-1, j+1);
				}
				if(down){
					if(!gridLayout[i+1][j].isRevealed())
					// Down
					revealTile(i+1, j);
					
					// downleft
					if (left && !gridLayout[i+1][j-1].isRevealed() && gridLayout[i+1][j-1].getType() == NUM_TILE )
						revealTile(i+1, j-1);
					
					// downright
					if (right && !gridLayout[i+1][j+1].isRevealed() && gridLayout[i+1][j+1].getType() == NUM_TILE)
						revealTile(i+1, j+1);
				}
				
				if(left && !gridLayout[i][j-1].isRevealed())
					// left
					revealTile(i, j-1);
				
				if(right && !gridLayout[i][j+1].isRevealed())
					// right
					revealTile(i, j+1);
	
		} // fin EMPTY_TILE
	} // fin méthode
			
	/* ------------------------------------------------------------------------- *
	 * Crée une grille de cases cachées par défaut
	 * ------------------------------------------------------------------------- */
	public Tile[][] createGridLayout(int[][] minesData) throws MSException{ 
		try{
			// Par défaut tout les cases sont empty
			for (int i = 0; i < height; i++){
				for(int j = 0 ; j < width; j++){
					gridLayout[i][j] = new Tile (EMPTY_TILE);	// Info dans tile pour ligne / colonne ?
				}
			}
			// On place les bombes
			fillMines(minesData);
			for (int i =0; i<nbreMines;i++){
				System.out.println(minesData[i][0] + "," + minesData[i][1]);
			}
			
			// On place les "numbered tile"
			fillNumbers();
			
		} catch(IndexOutOfBoundsException e){
			System.err.println("Error while creating grid : exceed index");
		}
		return gridLayout;
	}
	
	public int getWidth(){return width;}
	
	public int getHeight(){return height;}
	
	public int getNbreFlagged(){return nbreFlagged;}
	
	/* ------------------------------------------------------------------------- *
	 * Gère le flag click sur un élément de la grille et est capable de 
	 * déflaguer si nécessaire tout en màj le nombre de drapeaux dans la grille
	 * ------------------------------------------------------------------------- */
	public void flagClick(int x, int y){
		if( gridLayout[y][x].isRevealed() == false){
			if (gridLayout[y][x].isFlagged() == true){
				gridLayout[y][x].deflag(); 		
				nbreFlagged --;
			}
			else if (nbreFlagged < nbreFlag){
				gridLayout[y][x].flag();
				nbreFlagged++;
			}
		}
	}
	
	public boolean isWon(){
		if(nbreTiles - nbreTilesRevealed == nbreMines)
			return true;
		else  return false;	
	}
	
	public boolean isLost(){return lost;}
	
	public Tile[][] getGridLayout(){return gridLayout;}
	
}

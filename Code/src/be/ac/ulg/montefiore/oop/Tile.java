package be.ac.ulg.montefiore.oop;

import static be.ac.ulg.montefiore.oop.graphics.MinesweeperView.*;

/* ------------------------------------------------------------------------- *
 * Classe qui définit la notion de case, les informations associciées et les
 *  opérations pouvant être effectuée dessus
 *  
 *  NB : S'il avait existé d'autres types de tiles, l'on aurait pu considérer
 *  le fait de sous-diviser cette classe ou encore d'en faire un type abstract,
 *  toutefois, pour cette applicatuin, cela n'en vaut pas la peine car
 *  cela alourdirais inutilement le code à mon sens.
 * ------------------------------------------------------------------------- */
public class Tile {
	
	private int type;
	private int number;
	private boolean revealed;
	private boolean flagged;
	
	public static final int EMPTY_TILE = 0;
	public static final int NUM_TILE = 1;
	public static final int MINE_TILE = 2;

	
	public Tile(int type){
		this.type = type;
		revealed = false;
		flagged = false;
		number = 0; // Numéros associé à une NUM_TILE
	}
	
	public int getType(){return type;}
	public boolean isRevealed(){return revealed;}
	public boolean isFlagged(){return flagged;}
	
	public void reveal(){revealed = true; flagged = false;}
	
	public void flag(){flagged = true;}
	
	public void deflag(){flagged = false;}
	
	public int getNumber(){return number;}
	
	/* ------------------------------------------------------------------------- *
	 * Modifie le type de case ainsi que son numéro
	 * Permet ainsi de fixer le type d'une case à NUM_TILE et de lui affecter un numéro
	 * IN : le numéros associé (int)
	 * ------------------------------------------------------------------------- */
	public void setNumTile(int newNumber) throws MSException{
		
		if(number > 8 && number < 1)
			throw new MSException("Bad number for NUM_TILE");
		type = NUM_TILE;
		number = newNumber;
	}
	
	/* ------------------------------------------------------------------------- *
	 * Modifie le type de case (-> mine/empty)
	 * IN : le nouveau type (int)
	 * ------------------------------------------------------------------------- */
	public void setType(int newType) throws MSException{
		if(type != MINE_TILE && type != EMPTY_TILE){
			throw new MSException("Bad constant for tile");
		}
		type = newType;
		number = 0;
	}
	
	/* ------------------------------------------------------------------------- *
	 * Convertit les conventions de cette classe pour la représentation des cases à 
	 * celles utilisées par MinesweeperView
	 * IN : exploded, lost ; deux booléens pour détecter la mine explosée et les
	 * types de cases n'intervenants qu'en cas de "game over".
	 * ------------------------------------------------------------------------- */
	public int toView(boolean exploded, boolean lost){
		int GUItype = TILE_HIDDEN;
		if(!lost){ // partie en cours
			if(!revealed){
				if(!flagged)
					GUItype = TILE_HIDDEN;
				else GUItype = TILE_FLAG;
			}
		
			else if (type == EMPTY_TILE)
					GUItype = TILE_EMPTY;
			
			else if(type == NUM_TILE){
				switch (number){
					case 1 : GUItype = TILE_1; break;
					case 2 : GUItype = TILE_2; break;
					case 3 : GUItype = TILE_3; break;
					case 4 : GUItype = TILE_4; break;
					case 5 : GUItype = TILE_5; break;
					case 6 : GUItype = TILE_6; break;
					case 7 : GUItype = TILE_7; break;
					case 8 : GUItype = TILE_8; break;
				}
			}
		}
		else { // lost
			
			if(!revealed){ // On ne met à jour que les éléments non-révélés
				if(flagged && type != MINE_TILE){
					GUItype = TILE_INCORRECT;
				}

				else if(type == EMPTY_TILE)
					GUItype = TILE_EMPTY;
				
				else if(type == NUM_TILE){
					switch (number){
					case 1 : GUItype = TILE_1; break;
					case 2 : GUItype = TILE_2; break;
					case 3 : GUItype = TILE_3; break;
					case 4 : GUItype = TILE_4; break;
					case 5 : GUItype = TILE_5; break;
					case 6 : GUItype = TILE_6; break;
					case 7 : GUItype = TILE_7; break;
					case 8 : GUItype = TILE_8; break;
					}
				}
				else {// Mine jamais découverte
					GUItype = TILE_MINE;
				}
			}
			if(exploded){
				GUItype = TILE_EXPLODED;
			}
			revealed = true; flagged = false;
		}
		return GUItype;
	}
}


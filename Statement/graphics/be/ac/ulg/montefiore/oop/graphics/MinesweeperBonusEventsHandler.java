package be.ac.ulg.montefiore.oop.graphics;

/**
 * Interface that classes belonging to programs using this library must
 * implement in order to handle user actions such as left and right-clicking on
 * a tile.
 *
 * This interface must be implemented by students who want to do the bonus
 * question. If you do not want to implement the bonus, please take a look at
 * the {@link MinesweeperEventsHandler} interface.
 *
 * @author  Benjamin Laugraud
 * @version 1.0
 */
public interface MinesweeperBonusEventsHandler extends MinesweeperEventsHandler {
  /**
   * Method informing programs using this library that the player asked to start
   * a new game with the current level of difficulty.
   */
  void newGame();
}

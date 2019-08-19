package be.ac.ulg.montefiore.oop.graphics;

/**
 * Interface that classes belonging to programs using this library must
 * implement in order to handle user actions such as left and right-clicking on
 * a tile.
 *
 * This interface must be implemented by students who do not want to do the
 * bonus question. If you want to implement the bonus, please take a look at the
 * {@link MinesweeperBonusEventsHandler} interface.
 *
 * @author  Benjamin Laugraud
 * @version 1.0
 */
public interface MinesweeperEventsHandler {
  /**
   * Method informing programs using this library that the player performed a
   * left-click on a given tile. Note that the coordinates (0,0) correspond to
   * the tile at the top-left corner of the grid.
   *
   * @param x
   *        The horizontal coordinate the given tile.
   * @param y
   *        The vertical coordinate of the given tile.
   */
  void leftClickTile(final int x, final int y);

  /**
   * Method informing programs using this library that the player performed a
   * right-click on a given tile. Note that the coordinates (0,0) correspond to
   * the tile at the top-left corner of the grid.
   *
   * @param x
   *        The horizontal coordinate the given tile.
   * @param y
   *        The vertical coordinate of the given tile.
   */
  void rightClickTile(final int x, final int y);

  /**
   * Method returning the name of the student implementing the project. The
   * returned name will be credited in the About box.
   *
   * @return A string containing the name of the student implementing this
   *         interface.
   */
  String getStudentName();
}

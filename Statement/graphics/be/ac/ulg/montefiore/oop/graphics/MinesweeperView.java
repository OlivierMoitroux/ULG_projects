package be.ac.ulg.montefiore.oop.graphics;

/**
 * This interface must be implemented in order to manipulate a graphical
 * representation of the game.
 *
 * @author  Benjamin Laugraud
 * @version 1.0
 */
public interface MinesweeperView extends MinesweeperConstants {
  /**
   * Method allowing to update the state of the grid. Such a state must be
   * described using a two-dimensional array with dimensions compliant to the
   * ones of the grid. Each cell of this array must be filled with a tile
   * constant provided by this interface. The cell at coordinates (0,0)
   * corresponds to the tile at the top-left corner of the grid.
   * <p>
   * Note that invoking this method acts on the state of the window. You should
   * take a look at the {@link #refreshWindow()} method to graphically represent
   * all state modifications performed on the window.
   *
   * @param  grid
   *         The new state of the grid compliant to the format given above.
   *
   * @throws NullArrayException
   *         Exception thrown when the array of the grid parameter (or one of
   *         its columns array) is null.
   *
   * @throws BadHeightException
   *         Exception thrown when the height of the array of the grid parameter
   *         is not equal to the one of the window.
   *
   * @throws BadWidthException
   *         Exception thrown when the width of at least one column array of the
   *         grid parameter is not equal to the one of the window.
   *
   * @throws BadTileConstantException
   *         Exception thrown when a cell in the array of the grid parameter is
   *         described using an unknown tile constant.
   *
   * @see    #refreshWindow()
   */
  void updateGrid(final int[][] grid)
    throws NullArrayException, BadHeightException, BadWidthException,
           BadTileConstantException;

  /**
   * Method allowing to update the number of flags placed by the player.
   * <p>
   * By default, this number is initialized to 0. As a consequence, it is not
   * necessary to invoke this method before the first flag is placed.
   * <p>
   * Note that invoking this method act on the state of the window. You should
   * take a look at the {@link #refreshWindow()} method to graphically represent
   * all state modifications performed on the window.
   *
   * @param  number
   *         The new number of flags placed by the player.
   *
   * @see    #refreshWindow()
   */
  void updateFlagsNumber(final int number);

  /**
   * Method allowing to tell the player that the game has been won. After
   * invoking this method, the events related to the mouse will be ignored by
   * the graphical user interface, as well as new calls to this method, or the
   * {@link #lose()} method.
   * <p>
   * If the bonus is implemented (see {@link MinesweeperBonusEventsHandler}),
   * the events related to the mouse will be automatically reactivated after a
   * new game (the reactivation being handled by the class implementing this
   * interface).
   * <p>
   * Note that invoking this method acts on the state of the window. You should
   * take a look at the {@link #refreshWindow()} method to graphically represent
   * all state modifications performed on the window.
   *
   * @see    #refreshWindow()
   */
  void win();

  /**
   * Method allowing to tell the player that the game has been lost. After
   * invoking this method, the events related to the mouse will be ignored by
   * the graphical user interface, as well as new calls to this method, or the
   * {@link #win()} method.
   * <p>
   * If the bonus is implemented (see {@link MinesweeperBonusEventsHandler}),
   * the events related to the mouse will be automatically reactivated after a
   * new game (the reactivation being handled by the class implementing this
   * interface).
   * <p>
   * Note that invoking this method acts on the state of the window. You should
   * take a look at the {@link #refreshWindow()} method to graphically represent
   * all state modifications performed on the window.
   *
   * @see    #refreshWindow()
   */
  void lose();

  /**
   * Method allowing to graphically represent all state modifications performed
   * using the other methods of this interface. Keep in mind that these methods
   * act on a state and not on the graphical representation of this state.
   * <p>
   * Note that invoking this method for the first time makes the window visible.
   *
   * @see    #refreshWindow()
   */
  void refreshWindow();
}


|;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
|;                                                                             ;
|;                             CONSTANTS                                       ;
|;                             *********                                       ;
|;                                                                             ;
|;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;

OPEN_H0__:
  LONG(0xFFFFFF00)

OPEN_H1__:
  LONG(0xFFFF00FF)

OPEN_H2__:
  LONG(0xFF00FFFF)

OPEN_H3__:
  LONG(0x00FFFFFF)

OPEN_V0__:
  LONG(0xFFFFFFE1)

OPEN_V1__:
  LONG(0xFFFFE1FF)

OPEN_V2__:
  LONG(0xFFE1FFFF)

OPEN_V3__:
  LONG(0xE1FFFFFF)

WORDS_PER_MEM_LINE = 8
WORDS_PER_ROW = 64
CELLS_PER_WORD = 4

|;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
|;                                                                             ;
|;                             MACROS                                          ;
|;                             ******                                          ;
|;                                                                             ;
|;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;

|; get the row number at given index
|; Ra = index , Rb = nbCol
.macro rowFromIndex(Ra, Rb, Rc) DIV(Ra, Rb, Rc)

|;------------------------------------------------------

|; get the row number at given index
|; Ra = index , CC = nbCol
.macro rowFromIndexC(Ra, CC, Rc) DIVC(Ra, CC, Rc)

|;------------------------------------------------------

|; get the column of the cell at given index (Rc should be different from Ra and Rb)
|;Ra = index , Rb = nbCol
.macro colFromIndex(Ra, Rb, Rc) MOD(Ra, Rb, Rc)

|;------------------------------------------------------

|; get the column of the cell at given index (Rc should be different from Ra)
|; Ra = index , CC = nbCol
.macro colFromIndexC(Ra, CC, Rc) MODULOC(Ra, CC, Rc)

|;------------------------------------------------------

|; xor swap algorithm
|; X = R1, Y = R2
.macro SWAP(Ra, Rb) XOR(Ra, Rb, Ra) XOR(Rb, Ra, Rb) XOR(Ra, Rb, Ra)

|;------------------------------------------------------

|; Reg[Ra] <- Reg[Ra] + 1
.macro INC(Ra) ADDC(Ra, 1, Ra)

|;------------------------------------------------------

|; Reg[Ra] <- Reg[Ra] - 1
.macro DEC(Ra) SUBC(Ra, 1, Ra)

|;------------------------------------------------------

|; Reg[Rc] <- Reg[Ra] mod CC (Rc should be different from Ra)
.macro MODULOC(Ra, CC, Rc) DIVC(Ra, CC, Rc) MULC(Rc, CC, Rc) SUB(Ra, Rc, Rc)

|;------------------------------------------------------

|; Get the address of the element at index Reg[Rb] of the array starting
|; at address Reg[Ra] and store it in Reg[Rc]
|; Ra = array ( <=> &array[0] ), Rb = index, Rc <- &array[index]
|; NB: 1st element of the array is at index 0
.macro getAddrElement(Ra, Rb, Rc) {
  MULC(Rb, 4, Rc)                       |; compute real index (offset) to access memory
  ADD(Ra, Rc, Rc)
}

|;------------------------------------------------------

|; Set all elements of the array Ra (of size Reg[Rb]) to zero
|; Ra = &array[0] , Rb = size of array
.macro setToZero(Ra, Rb) {
      PUSH(Rb)
      PUSH(R1)                          |; calculation register
    loopMacro__:                        |; ~while(Rb >= 0)~
      DEC(Rb)                           |; from index size-1 to 0
      getAddrElement(Ra, Rb, R1)        |; array[Rb] = 0
      ST(R31, 0, R1)

      BF(Rb, endMacro__)                |; Rb == 0 <=> all mods are done, exit loop
      BR(loopMacro__)

    endMacro__:
      POP(R1)
      POP(Rb)
}

|;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
|;                                                                             ;
|;                            AUXILIARY FUNCTIONS                              ;
|;                            *******************                              ;
|;                                                                             ;
|;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;

|;----------------------------------------------------------------------------;|
|; FUNCTION    : connect                                                      ;|
|; DESCRIPTION : Opens a connection between two cells.                        ;|
|; ARGUMENTS   : 1) maze 2) source 3) dest 4) nbCol                           ;|
|; RETURN      : /                                                            ;|
|;----------------------------------------------------------------------------;|
connect__:
  PUSH(LP)
  PUSH(BP)
  MOVE(SP, BP)
  |; Backup of contents (to be restored later)
  PUSH(R1)
  PUSH(R2)
  PUSH(R3)
  PUSH(R4)
  PUSH(R5)                        |; calculation register
  PUSH(R6)                        |; calculation register

  |; Loading arguments
  LD(BP, -12, R1)
  LD(BP, -16, R2)
  LD(BP, -20, R3)
  LD(BP, -24, R4)

  maze    = R1
  source  = R2
  dest    = R3
  nbCol   = R4
  tmp     = R5
  tmp2    = R6

  |; make sure source is before dest in the maze (source < dest)
  CMPLT(source, dest, R0)
  BT(R0, sourceLessThanDest__)

    |; if true, (source > dest), need to swap
    SWAP(source, dest)

  |; otherwise,
  sourceLessThanDest__:

  |; dest_row = row_from_index(dest, nbcol)
  rowFromIndex(dest, nbCol, R0)                |; R0 <- dest_row

  |; row_offset = dest_row * WORDS_PER_ROW
  MULC(R0, WORDS_PER_ROW, tmp)                 |; tmp <- row_offset

  |; source_col = col_from_index(source, nbCol)
  colFromIndex(source, nbCol, tmp2)            |; tmp2 <- source_col

  |; word_offset_in_line = row_from_index(source_col, CELLS_PER_WORD)
  rowFromIndexC(tmp2, CELLS_PER_WORD, R0)      |; R0 <- word_offset_in_line

  |; word_offset = row_offset + word_offset_in_line
  ADD(tmp, R0, tmp)                            |;  tmp <- word_offset

  MOVE(tmp2, R0)                               |; Because Ra must be different than Rc to use colFromIndex()

  |; byte_offset = col_from_index(source_col, CELLS_PER_WORD)
  colFromIndexC(R0, CELLS_PER_WORD, tmp2)      |; tmp2 <- byte_offset

  |; R1 = maze, R2 = source, R3 = dest, R4 = nbCol, R5 = tmp = word_offset,
  |; R6 = tmp2 = byte_offset
  word_offset = tmp
  byte_offset = tmp2

  |; Open vertical connection ? { if(dest - source > 1) }
  ADDC(source, 1, R0)
  CMPLT(R0, dest, R0)                           |; (<=> dest  > 1 + source)
  BF(R0, No__)

  Yes__:                                        |; YES, open vertical connection

    |; openVertCnct(maze, byte_offset, word_offset)
    PUSH(word_offset)
    PUSH(byte_offset)
    PUSH(maze)
    CALL(openVertCnct__, 3)                     |; No DEALLOCATE required because we used call with 2 args
    BR(connectEnd__)


  No__:                                         |; NO, open horizontal connection instead

    |; openHorCnct(byte_offset, word_offset)
    PUSH(word_offset)
    PUSH(byte_offset)
    PUSH(maze)
    CALL(openHorCnct__, 3)
    |; BR(connectEnd__)

  connectEnd__:
    |; restore previous contents
    POP(R6)
    POP(R5)
    POP(R4)
    POP(R3)
    POP(R2)
    POP(R1)
  	POP(BP)
  	POP(LP)
  	RTN()

|;----------------------------------------------------------------------------;|
|; FUNCTION    : openVertCnct                                                 ;|
|; DESCRIPTION : Opens a connection between two vertical cells.               ;|
|; ARGUMENTS   : 1) maze 2) source 3) dest 4) nbCol                           ;|
|; RETURN      : /                                                            ;|
|;----------------------------------------------------------------------------;|

openVertCnct__:
  PUSH(LP)
  PUSH(BP)
  MOVE(SP, BP)
  |; Backup of contents (to be restored later)
  PUSH(R1)
  PUSH(R2)                         |; calculation register
  PUSH(R3)                         |; calculation register
  PUSH(R4)                         |; calculation register
  PUSH(R5)
  PUSH(R6)

  |; Loading arguments
  LD(BP, -12, R1)                  |; maze
  LD(BP, -16, R5)                  |; byte_offset
  LD(BP, -20, R6)                  |; word_offset

  maze         = R1
  mask         = R2
  i            = R3
  index        = R4
  byte_offset  = R5
  word_offset  = R6

  |; if (byte_offset == 0) {mask = OPEN_V_0;}
  BEQ(byte_offset, openV0__)

  |; if (byte_offset == 1) {mask = OPEN_V_1;}
  CMPEQC(byte_offset, 1, R0)
  BT(R0, openV1__)

  |; if (byte_offset == 2) {mask = OPEN_V_2;}
  CMPEQC(byte_offset, 2, R0)
  BT(R0, openV2__)

  |; else (we equal mask directly to the constant OPEN_V_3)
  LDR(OPEN_V3__, mask)                          |; LDR() because CMOVE works with only 16 bits
  BR(TwoWords2Update__)

  openV0__:

    LDR(OPEN_V0__, mask)
    BR(TwoWords2Update__)

  openV1__:

    LDR(OPEN_V1__, mask)
    BR(TwoWords2Update__)

  openV2__:

    LDR(OPEN_V2__, mask)
    BR(TwoWords2Update__)

  TwoWords2Update__:                             |; update the maze (modify dynamic memory)

    |; for (int i = 0; i < 2; ++i)
    CMOVE(0, i)                                  |; i = 0
    loopVert__:

      MULC(i, WORDS_PER_MEM_LINE, index)         |; index = word_offset + i * WORDS_PER_MEM_LINE
      ADD(word_offset, index, index)

      |; maze[index] &= mask
      addrMazeIndex = index                      |; /!\ Same register BUT not the same in concept however !
      getAddrElement(maze, index, addrMazeIndex) |; addrMazeIndex is &maze[index]
      LD(addrMazeIndex, 0, R0)

      |; update the word by applying the mask:
      AND(R0, mask, R0)
      ST(R0, 0, addrMazeIndex)

      INC(i)                                     |; ++i
      CMPLTC(i, 2, R0)
      BF(R0, openVertCnctEnd__)
      BR(loopVert__)

openVertCnctEnd__:
  POP(R6)
  POP(R5)
  POP(R4)
  POP(R3)
  POP(R2)
  POP(R1)
  POP(BP)
  POP(LP)
  RTN()

|;----------------------------------------------------------------------------;|
|; FUNCTION    : openHorCnct                                                  ;|
|; DESCRIPTION : Opens a connection between two horizontal cells.             ;|
|; ARGUMENTS   : 1) maze 2) source 3) dest 4) nbCol                           ;|
|; RETURN      : /                                                            ;|
|;----------------------------------------------------------------------------;|

openHorCnct__:
  PUSH(LP)
  PUSH(BP)
  MOVE(SP, BP)

  |; Backup of contents (to be restored later)
  PUSH(R1)
  PUSH(R2)                          |; calculation register
  PUSH(R3)                          |; calculation register
  PUSH(R4)                          |; calculation register
  PUSH(R5)
  PUSH(R6)

  |; Loading arguments
  LD(BP, -12, R1)                   |; maze
  LD(BP, -16, R5)                   |; byte_offset
  LD(BP, -20, R6)                   |; word_offset

  maze         = R1
  mask         = R2
  i            = R3
  index        = R4
  byte_offset  = R5
  word_offset  = R6

  |; if (byte_offset == 0) {mask = OPEN_H_0;}
  BEQ(byte_offset, openH0__)

  |; if (byte_offset == 1) {mask = OPEN_H_1;}
  CMPEQC(byte_offset, 1, R0)
  BT(R0, openH1__)


  |; if (byte_offset == 2) {mask = OPEN_H_2;}
  CMPEQC(byte_offset, 2, R0)
  BT(R0, openH2__)


  |; else (we equal directly mask to the constant OPEN_H_3)
  LDR(OPEN_H3__, mask)                          |; LDR() because CMOVE works with only 16 bits
  BR(FourWords2Update)

  openH0__:
    LDR(OPEN_H0__, mask)
    BR(FourWords2Update)

  openH1__:
    LDR(OPEN_H1__, mask)
    BR(FourWords2Update)

  openH2__:
    LDR(OPEN_H2__, mask)
    BR(FourWords2Update)

  FourWords2Update:                              |; update the maze (modify dynamic memory)

    |; for (int i = 3; i < 7; ++i)
    CMOVE(3,i)                                   |; i = 3
    loopHor__:

      MULC(i, WORDS_PER_MEM_LINE, index)         |; index = word_offset + i * WORDS_PER_MEM_LINE
      ADD(word_offset, index, index)

      |; maze[index] &= mask
      addrMazeIndex = index                      |; Same register BUT not the same in concept however !
      getAddrElement(maze, index, addrMazeIndex) |; addrMazeIndex is &maze[index]
      LD(addrMazeIndex, 0, R0)

      |; update the word by applying the mask:
      AND(R0, mask, R0)
      ST(R0, 0, addrMazeIndex)

      INC(i)                                     |; ++i
      CMPLTC(i, 7, R0)
      BF(R0, openHorCnctEnd__)
      BR(loopHor__)

openHorCnctEnd__:
  POP(R6)
  POP(R5)
  POP(R4)
  POP(R3)
  POP(R2)
  POP(R1)
  POP(BP)
  POP(LP)
  RTN()

|;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
|;                                                                             ;
|;                            MAIN FUNCTION                                    ;
|;                            *************                                    ;
|;                                                                             ;
|;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;

|;----------------------------------------------------------------------------;|
|; FUNCTION    : perfect_maze                                                 ;|
|; DESCRIPTION : builds a perfect maze in the dynamic memory starting from a  ;|
|;               fully closed maze                                            ;|
|; ARGUMENTS   :                                                              ;|
|; 1) maze     : address of the first word of the maze                        ;|
|; 2) rows     : number of rows in the maze                                   ;|
|; 3) cols     : number of columns in the maze                                ;|
|; 4) visited  : the bitmap indicating which cells were already               ;|
|;      visited/attached to the maze (visited[i] contains 1 if there is a path;|
|;      between c_i and c_start (i.e. the initial cell), 0 otherwise)         ;|
|; 5) curr_cell: the cell the maze should be constructed from                 ;|
|; RETURN      : /                                                            ;|
|;----------------------------------------------------------------------------;|

perfect_maze:

  PUSH(LP)
  PUSH(BP)
  MOVE(SP,BP)

  |; Backup of contents (to be restored later)
  PUSH(R1)
  PUSH(R2)
  PUSH(R3)
  PUSH(R4)
  PUSH(R5)
  PUSH(R6)                       |; calculation register
  PUSH(R7)                       |; calculation register
  PUSH(R8)                       |; calculation register
  PUSH(R9)                       |; calculation register
  PUSH(R10)                      |; calculation register
  PUSH(R11)                      |; calculation register

  |; Loading arguments
  LD(BP, -12, R1)                |; maze
  LD(BP, -16, R2)                |; nb_rows
  LD(BP, -20, R3)                |; nb_cols
  LD(BP, -24, R4)                |; bitmap
  LD(BP, -28, R5)                |; start_cell (the random cell)

  maze                = R1
  nb_rows             = R2
  nb_cols             = R3       |; nbCol in connect (R4)
  bitmap              = R4
  start_cell          = R5
  n_valid_neighbours  = R6
  tmp                 = R7
  tmp2                = R8
  addrLocation        = R9       |; for lisibility of the code only
  neighbour           = R10
  neighbours          = R11

  curr_cell   = start_cell
  visited     = bitmap

  |; Set current cell as visited :
  |; visited[curr_cell / 32] |= (1 << (curr_cell % 32));
  CMOVE(1, tmp)
  MODULOC(curr_cell, 32, tmp2)
  SHL(tmp, tmp2, tmp2)                           |; tmp2 = (1 << (curr_cell % 32)
  DIVC(curr_cell, 32, tmp)
  getAddrElement(visited, tmp, addrLocation)
  LD(addrLocation, 0, tmp)
  OR(tmp,tmp2, tmp)
  ST(tmp, 0, addrLocation)
  |; visited[curr...] = visited[curr...] | (1<<..) where visited[curr...] is tmp

  |; Initialisation of the array "neighbours" (4 elements)
  MOVE(SP, neighbours)
  |; Allocate space on the stack for the array "neighbours" and set every el. to zero
  ALLOCATE(4)
  CMOVE(4, tmp2)
  setToZero(neighbours, tmp2)                    |; for a clean array without garbage

  CMOVE(0, n_valid_neighbours)

  col = tmp2                                     |; for lisibility
  colFromIndex(curr_cell, nb_cols, col)          |; col =  colFromIndex(curr_cell, nb_cols)

  checkLeftNeighbour__:                          |; if(col > 0)
    CMPLT(R31, col, R0)
    BF(R0, checkRightNeighbour__)                |; R0 == 0 <=> col <= 0, jump to next if()

    SUBC(curr_cell, 1, tmp)
    getAddrElement(neighbours, n_valid_neighbours, addrLocation)
    ST(tmp, 0, addrLocation)
    INC(n_valid_neighbours)

  checkRightNeighbour__:                         |; if (col < nb_cols - 1)

    SUBC(nb_cols, 1, tmp)
    CMPLT(col, tmp, R0)
    BF(R0, checkTopNeighbour__)                  |; if false, R0 == 0 and jmp to next if()

    ADDC(curr_cell, 1, tmp)
    getAddrElement(neighbours, n_valid_neighbours, addrLocation)
    ST(tmp, 0, addrLocation)
    INC(n_valid_neighbours)

  checkTopNeighbour__:                           |; if (row > 0)

    row = tmp2                                   |; for lisibility (and we don't need col=tmp2 anymore)
    rowFromIndex(curr_cell, nb_cols, row)        |; row = rowFromIndex(curr_cell, nb_cols)

    CMPLT(R31, row, R0)
    BF(R0, checkBottomNeighbour__)               |; R0 == 0 <=> row <= 0, jump to next if()

    SUB(curr_cell, nb_cols, tmp)
    getAddrElement(neighbours, n_valid_neighbours, addrLocation)
    ST(tmp, 0, addrLocation)
    INC(n_valid_neighbours)

  checkBottomNeighbour__:                        |; if (row < nb_rows - 1)

    SUBC(nb_rows, 1, tmp)
    CMPLT(row, tmp, R0)
    BF(R0, xploreValidNeighbours__)              |; if false, R0 == 0 and let's begin to explore the valid
                                                 |; neighbours found (element(s) != 0 in neighbours[])

    ADD(curr_cell, nb_cols, tmp)
    getAddrElement(neighbours, n_valid_neighbours, addrLocation)
    ST(tmp, 0, addrLocation)
    INC(n_valid_neighbours)

  xploreValidNeighbours__:                       |; while (n_valid_neighbours > 0)

    CMPLT(R31, n_valid_neighbours, R0)           |; n_valid_neighbours > 0
    BF(R0, endPerfectMaze__)                     |; R0 == 0 <=> n_valid_neighbour <= 0, exit loop

    loopXplore__:

      |; Let's take a random number

      RANDOM()                                   |; RANDOM() res is in R0 ([0,2^32-1])

      PUSH(R0)
    	CALL(abs__, 1)                             |; To get rid of bugs from MOD (only positive value)
      |; alternative :
      |; ANDC(r0, 0xFF, r0) => random res in [0, 255] (sign bit set to zero)

      MOD(R0, n_valid_neighbours, tmp)           |; tmp <- random_neigh_index {= rand() % n_valid_neighbours}

      getAddrElement(neighbours, tmp, addrLocation)
      LD(addrLocation, 0, neighbour)

      |; Put the taken neighbour at the end of neighbours array to avoid picking it a second time (cfr. MOD)
		  |; <=> SWAP(neighbours + n_valid_neighbours - 1, neighbours + random_neigh_index);

      |; addrLocation is  &(neighbours[n_valid_neighbours-1])
      SUBC(n_valid_neighbours, 1, tmp2)
      getAddrElement(neighbours, tmp2, addrLocation)

      |; tmp2 = neighbours[n_valid_neighbours-1]
      LD(addrLocation, 0, tmp2)

      |; Reminder : tmp is still random_neigh_index (optimisation)
      |; tmp = &(neighbours[random_neigh_index])
      getAddrElement(neighbours, tmp, tmp)

      |; We want to store the value "tmp2" now stored at address "addrLocation" at the address "tmp".
      |; However, we need first to load the value stored at the address "tmp"
      |; into the register "R0" in order to avoid loosing the value. Then we will be able to
      |; store the content of R0 at the address "addrLocation".

      LD(tmp, 0, R0)                              |; R0 = neighbours[random_neigh_index]
      ST(tmp2, 0, tmp)
      ST(R0, 0, addrLocation)

      DEC(n_valid_neighbours)

      |; visited_bit = (visited[neighbour / 32] >> (neighbour % 32)) & 1;
      DIVC(neighbour, 32, tmp)                    |; We don't need anymore the old content of tmp
      getAddrElement(visited, tmp, addrLocation)
      LD(addrLocation, 0, tmp )                   |; tmp  = visited[neighbour/32]
      MODULOC(neighbour, 32, tmp2)                |; tmp2 = neighbour % 32
      SHR(tmp, tmp2, tmp)                         |; tmp  = visited[neighbour / 32] >> (neighbour % 32)
      visited_bit = tmp2                          |; for lisibility
      ANDC(tmp, 1, visited_bit)

      |; if(visited_bit == 1), bit has been already visited => go to next iteration
      CMPEQC(visited_bit, 1, R0)
      BT(R0, xploreValidNeighbours__)

      |; Otherwise, let's connect and explore recursively
      PUSH(nb_cols)
      PUSH(neighbour)                             |; dest
      PUSH(curr_cell)                             |; source
      PUSH(maze)
      CALL(connect__, 4)

      |; We do not deallocate neighbours here because we still need it in the loop xploreValidNeighbours__

      PUSH(neighbour)
      PUSH(visited)
      PUSH(nb_cols)
      PUSH(nb_rows)
      PUSH(maze)
      CALL(perfect_maze, 5)
      BR(xploreValidNeighbours__)

  endPerfectMaze__:
      DEALLOCATE(4)                               |; Free the space  used by the array neighbours
      POP(R11)
      POP(R10)
      POP(R9)
      POP(R8)
      POP(R7)
      POP(R6)
      POP(R5)
      POP(R4)
      POP(R3)
      POP(R2)
      POP(R1)

      POP(BP)
      POP(LP)

      RTN()

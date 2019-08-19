/**--------------------------------------------------------------------------- /
*                         Square bounce project 2
*                         ***********************
* @author O. Moitroux & P. Hockers
* @date 15.12.17
/ ----------------------------------------------------------------------------*/

/* including standard library */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdbool.h>
#include <ctype.h>
#include <string.h>

// including System V
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/msg.h>

/* including user libraries */
#include "constants.h"
#include "output.h"

/* Structures */
struct square_t {
  int x;
  int y;
  int color;
  int speedx;
  int speedy;
};
typedef struct square_t square;

union semun {
  int val;                     // value for SETVAL
  struct  semid_ds*buf;       // buffer for IPC_STAT, IPC_SET
  unsigned  short int*array;  //  arrayfor GETALL, SETALL
  struct  seminfo*__buf;      // buffer for IPC_INFO
};

// Buffer used to exchange informations between workers
struct mymsgbuf{
  long mtype;  // msg type (1 or 2)
  int speedx;
  int speedy;
};

/* Method signatures */
// main() functions:
bool hasIntersection(square a, square b);
bool overlapWithPrev(square* , int);
void manualInitialization(square*);
void randomInitialization(square*);
void displaySquares_table(square*);
void resetTable(int[SIZE_X][SIZE_Y]);
void updateTable(int[SIZE_X][SIZE_Y], square*);

// Processes:
void master(int* segptr, int semid, int[SIZE_X][SIZE_Y] , square* squares_table);
void worker(int msgqueue_id, int* segptr, int semid, int id, square obj);
void controler(int msgqueue_id, int* segptr, int semid, int shmid);

// Processes functions:
void updatePriorityList(int* segptr);
void updateSquaresTable(int* segptr, square* squares_table);
int hasOverlap(int x, int y, int* segptr, int id);
bool thisIDMorePriority(int* segptr, int id, int id2);
int findInPQ(int* segptr, int p_id);


/* Method signatures for multi_core implementation of system V*/
// Shared memory:
void writeShm(int* segptr, int index, int value);  // write in shared memory()
int readShm(int* segptr, int index);               // read in shared memory()
void removeShm(int shmid);                         // mark shared memory for deletion()

// Semaphores:
void wait(int sid, int member);     // locksem()
void signal(int sid, int member);   // unlocksem()
void removeSem(int semid);

// blocking queue messaging:
void sendMsg(int qid, struct mymsgbuf* qbuf, long type, int speedx, int speedy);
int  readMsg( int qid, struct mymsgbuf* qbuf, long type);
void removeQueue(int qid);

/* GLOBAL Variable */

int SQUARE_CNT;
size_t SEGSIZE;  // Nb of shared memory var.
int SEMSIZE;     // Nb of semaphores
// shared memory indexes:
int STOP_SHM;
int XPOS_SHM;
int YPOS_SHM;
int PRIORITY_LIST_SHM;
// semaphore indexes:
int EXITED_SEM;
int CHECK_COLLISIONS_SEM;
int END_CHECK_COLLISIONS_SEM;
int COMPUTE_SEM;
int WALL_COMPUTED_SEM;

// NB : all the semaphore names & shared memory names hide indexes in fact

/**---------------------------------------------------------------------------*
* Asks the user to choose between random or manual initilization and initializes
* the squares table accordingly. Creates several processes and performs all the
* required declarations and initializations required to make the code running
*
* @parameter nb of iterations, square count
*  ---------------------------------------------------------------------------*/
int main(int argc, char** argv){

  //The eventual parameter is the number of SQUARE_CNT
	if(argc > 1){
    SQUARE_CNT = atoi(argv[1]);
  }
  else if (argc == 1){
    printf("SQUARE_CNT default initialized to 3\n");
    SQUARE_CNT = 3;
  }
  else{
    fprintf(stderr, "call should be : ./xxxx SQUARE_CNT");
    exit(1);
  }

  /* First initilization (with user): */
  square squares_table[SQUARE_CNT];           // To store position and velocities of squares
  int table_of_pixels[SIZE_X][SIZE_Y] = { 0 };	// Store the states of the pixels

  printf("Initiliazing the %d squares : \n", SQUARE_CNT);
  printf("Random init. ? [y/n] : ");
  char choice;
  scanf("%c", &choice);
  if(choice == 'n')
    manualInitialization(squares_table);
  else if(choice == 'y')
    randomInitialization(squares_table);
  else{
    fprintf(stderr, "Bad input");
    exit(1);
  }

  // Display initialization
  displaySquares_table(squares_table);

  resetTable(table_of_pixels);

  updateTable(table_of_pixels, squares_table);

  //Initializes SDL and the colours
  init_output();

  /* Multi-Core variable declaration */
  int semid;    // to store semaphore
  int* segptr;  // to store shared memory

  SEMSIZE = 3 * SQUARE_CNT + 2; // global var (easier to check out of range in wait()/signal() )
  /*
  * COMPUTE_SEM               -> SQUARE_CNT like this
  * WALL_COMPUTED_SEM         -> SQUARE_CNT like this
  * CHECK_COLLISIONS_SEM      -> SQUARE_CNT like this
  * EXITED_SEM                -> 1 like this
  * END_CHECK_COLLISIONS_SEM  -> 1 like this
  */

  SEGSIZE = 1 + 3 * SQUARE_CNT; // global var (easier to check out of range in writeShm() / readShm() )
  /*
  * STOP_SHM;           -> 1 like this
  * XPOS_SHM;           -> SQUARE_CNT like this
  * YPOS_SHM;           -> SQUARE_CNT like this
  * PRIORITY_LIST_SHM;  -> SQUARE_CNT like this
  */

  key_t key_mem, key_sem, key_q; // unique key for shared mem., sem. and queue
  pid_t pid;                     // process id
  int shmid;                     // shared memory id and semaphore id
  int id;
  union semun semopts;
  int msgqueue_id;

  /* Create unique key via call to ftok() */
  key_mem = ftok(".", 'M');
  key_sem = ftok(".", 'S');
  key_q   = ftok(".", 'Q');

  /* Open the shared memory segment -create if necessary */
  if((shmid = shmget(key_mem, (SEGSIZE + 1) * sizeof(int), IPC_CREAT|IPC_EXCL|0666)) == -1) {
    printf("Shared memory segment exists - opening as client\n");

    // Segment probably already exists - try as a client
    if((shmid = shmget(key_mem, (SEGSIZE + 1) * sizeof(int), 0)) == -1) {
      perror("shmget");
      exit(1);
    }
  }
  else {
    printf("Creating new shared memory segment\n");
  }

  /* Attach (map) the shared memory segment into the current process */
  if((segptr = (int*)shmat(shmid, 0, 0)) == (int*) - 1) {
    perror("shmat");
    exit(1);
  }

  /* Shared memory initialization */
  // initializes indexes to access shared memory vector (segptr) :
  STOP_SHM = 0;
  XPOS_SHM = 1;                           // [1:SQUARE_CNT]
  YPOS_SHM = SQUARE_CNT + 1;            // [SQUARE_CNT + 1 : 2*SQUARE_CNT + 1]
  PRIORITY_LIST_SHM = 2*SQUARE_CNT + 1; // ...

  // initializes elements in the shared memory vector :
  writeShm(segptr,STOP_SHM,0);
  for(int i = 0; i < SQUARE_CNT ; ++i){
    writeShm(segptr, XPOS_SHM + i, squares_table[i].x);
    writeShm(segptr, YPOS_SHM + i, squares_table[i].y);
  }
  updatePriorityList(segptr);

  /* Creating the semaphore array */
  printf("Attempting to create new semaphore set \n");

  if((semid = semget(key_sem, SEMSIZE, IPC_CREAT|IPC_EXCL|0666)) == -1) {
    fprintf(stderr, "Semaphore set already exists!\n");
    exit(1);
  }

  /* Initiliazing semaphores */

  // Initializes indexes to access semaphore array (semid)
  COMPUTE_SEM               = 0;                    // [0 : SQUARE_CNT-1]
  WALL_COMPUTED_SEM         = SQUARE_CNT;         // [SQUARE_CNT : 2 * SQUARE_CNT - 1]
  CHECK_COLLISIONS_SEM      = 2 * SQUARE_CNT;     // [2 * SQUARE_CNT : 3 * SQUARE_CNT-1]
  EXITED_SEM                = 3 * SQUARE_CNT;     // [3 * SQUARE_CNT]
  END_CHECK_COLLISIONS_SEM  = 3 * SQUARE_CNT + 1; // [3 * SQUARE_CNT + 1]

  // Initializes semaphore array (semid) elements
  for(int i = 0; i < SQUARE_CNT; ++i){
    semopts.val = 0;
    semctl(semid, COMPUTE_SEM + i , SETVAL, semopts);
    semopts.val = 0;
    semctl(semid, WALL_COMPUTED_SEM + i , SETVAL, semopts);
    semopts.val = 0;
    semctl(semid, CHECK_COLLISIONS_SEM + i, SETVAL, semopts);
  }
  semopts.val = 0;
  semctl(semid, EXITED_SEM, SETVAL, semopts);
  semopts.val = 0;
  semctl(semid, END_CHECK_COLLISIONS_SEM, SETVAL, semopts);

  /* Open the queue - create if necessary */
  if((msgqueue_id = msgget(key_q, IPC_CREAT|0660)) == -1){
    perror("msgget");
    exit(1);
  }

  /* Creating "worker" processes + the "controler" */
  id = 0;
  for(int nbProc = 0; nbProc < SQUARE_CNT + 1; nbProc++) {
    pid = fork();
    if(pid < 0) {
        perror("Process creation failed");
        exit(1);
    }
    if(pid == 0) {
      //This is a son
      usleep(2000000);
      if(nbProc < SQUARE_CNT){
        printf("Creating worker process with id = %d \n",  id);
        worker(msgqueue_id, segptr, semid, id, squares_table[id]);
      }
      else {
        printf("Creating controler process nwith id = %d \n", id);
        // Shouldn't be comented but, when uncomented -> crash
        // controler(msgqueue_id, segptr, semid, shmid);
      }
      nbProc = SQUARE_CNT + 1;
    }
    else {
      //This is the father
      id++;
    }
  }

  /* We enter the master's code */
  if(pid != 0)
    master(segptr, semid, table_of_pixels, squares_table); //TODO

  return 0;
}

// ---------------------Processes implementation------------------------------//

void master(int* segptr, int semid, int table_of_pixels[SIZE_X][SIZE_Y], square* squares_table){

  while(readShm(segptr, STOP_SHM) == 0){
    int i;

    /* Signal to workers that they should compute their next position */
    for(i = 0; i < SQUARE_CNT; ++i){
      signal(semid, COMPUTE_SEM + i);
    }

    /* Wait workers until they all computed their position */
    for(i = 0; i < SQUARE_CNT; ++i){
      wait(semid, WALL_COMPUTED_SEM + i );
    }

    /* Positions changed, update the priority of each square */
    updatePriorityList(segptr);

    /* Signaling to workers that they should check if some of them overlap with each other */
    // Thus, we signal firstly the one with the highest priority :
    //     =>  signal(check_collisions[priorityList[0]])
    signal(semid, CHECK_COLLISIONS_SEM + readShm(segptr, PRIORITY_LIST_SHM));

    /* wait until we are sure they all have computed their final position */
    wait(semid, END_CHECK_COLLISIONS_SEM);

    /* Update GUI */
    resetTable(table_of_pixels);
    updateSquaresTable(segptr, squares_table);
    // displaySquares_table(squares_table);
    updateTable(table_of_pixels, squares_table);
    update_output(table_of_pixels); // Apply the change on SDL display

    /* Wait a bit */
    usleep(15000);
  }
  signal(semid, EXITED_SEM);
}

void worker(int msgqueue_id, int* segptr, int semid, int id, square obj){

  struct mymsgbuf qbuf;  // buffer for message queue
  while(readShm(segptr, STOP_SHM) == 0) {

    /* Wait order from master process to start computing */
    wait(semid, COMPUTE_SEM + id);

    /* Moving x */
    obj.x += obj.speedx;
    if(obj.x > SIZE_X - SQUARE_WIDTH){ // right bound encountered
        obj.x =  SIZE_X - SQUARE_WIDTH;
        obj.speedx = -1;
    }
    if(obj.x < 0){ // left bound encountered
        obj.x = 0;
        obj.speedx = 1;
    }
    /* [moving y] */
    obj.y += obj.speedy;
    if(obj.y > SIZE_Y - SQUARE_WIDTH){ // upper bound encountered
        obj.y =  SIZE_Y - SQUARE_WIDTH;
        obj.speedy = -1;
    }
    if(obj.y < 0){ // lower bound encountered
        obj.y = 0;
        obj.speedy = 1;
    }

    /* Updating shared memory */
    // each worker writes in a different variable in shared memory & no read -> no mutex
    writeShm(segptr, XPOS_SHM + id, obj.x); // (shared_t) x[id] = obj.x
    writeShm(segptr, YPOS_SHM + id, obj.y); // (shared_t) y[id] = obj.y

    /* Notify master process that we are ready for the following */
    signal(semid, WALL_COMPUTED_SEM + id);  // signal(wall_computed[id]);

    /* Correcting possible overlaps */
    wait(semid, CHECK_COLLISIONS_SEM + id); // wait(check_collisions[id]);

    int id2 = hasOverlap(obj.x, obj.y, segptr, id);

    if(id2 != -1 && thisIDMorePriority(segptr, id, id2)) {
      sendMsg(msgqueue_id, (struct mymsgbuf*)&qbuf, 1, obj.speedx, obj.speedy); // <=> q! first <=> postToqueue1([obj.speedx, obj.speedy]);
      signal(semid, CHECK_COLLISIONS_SEM + id2); // signal(check_for_collisions[id2]);

      readMsg(msgqueue_id, &qbuf, 2); // q? second <=>  [speedx, speedy] = readFromQueue2();
      int speedx_id2 = qbuf.speedx;
      int speedy_id2 = qbuf.speedy;

      if(hasOverlap(obj.x, obj.y, segptr, id) == id2){ // overlap with the same square
        // They were at least by 2 pixels overlaped -> All in all, both have to move bakward (1pixel)
        obj.x -= obj.speedx;
        obj.y -= obj.speedy;
      }
      /* SWAP their speed */
      obj.speedx = speedx_id2;
      obj.speedy = speedy_id2;
      // call next worker in priority list
    }
    else if (id2 != -1 && !thisIDMorePriority(segptr, id, id2)) {
      // This woker have been woken up by a (collided) worker with higher priority
      readMsg(msgqueue_id, &qbuf, 1); // q? first <=>  [speedx, speedy] = readFromQueue1();
      int speedx_id2 = qbuf.speedx;
      int speedy_id2 = qbuf.speedy;

      /* Move one pixel backward, you hitted a priority square */
      obj.x -= obj.speedx;
      obj.y -= obj.speedy;

      sendMsg(msgqueue_id, (struct mymsgbuf*)&qbuf, 2,obj.speedx, obj.speedy); // <=> q! second <=> postToqueue2([obj.speedx, obj.speedy]);
      obj.speedx = speedx_id2;
      obj.speedy = speedy_id2;

      // This worker has already moved once. If it is signaled again, just wake up the next priority one
      wait(semid, CHECK_COLLISIONS_SEM + id);
    }
    if(readShm(segptr, PRIORITY_LIST_SHM + SQUARE_CNT - 1) != id) { // Not the last once
      // Let's signal the next worker in the priority list
      signal(semid, CHECK_COLLISIONS_SEM + readShm(segptr, PRIORITY_LIST_SHM + findInPQ(segptr, id) + 1));
    }
    else {
      // All workers done, this was the last one
      signal(semid, END_CHECK_COLLISIONS_SEM);
    }
  } // end of while
  signal(semid, EXITED_SEM);
}

void controler(int msgqueue_id, int* segptr, int semid, int shmid){
  /* Waiting for keyboard hit */
  getchar();
  // keyboard hit -> stop processes
  writeShm(segptr, STOP_SHM, 1); // STOP_SHM = 1
  /* wait that all processes (SQUARE_CNT workers + master) have finished looping properly */
  for(int nb_stopped = 0; nb_stopped < SQUARE_CNT + 1; ++nb_stopped) {
        wait(semid, EXITED_SEM + nb_stopped);
  }
  /* Deletion in memory */
  removeQueue(msgqueue_id);
  removeShm(shmid);
  removeSem(semid);
  // EXIT_SUCESS
}

//---------------------Functions for multi-core SYTEM V-----------------------//

/// locksem()
void wait(int sid, int member) {
  struct sembuf sem_lock = { 0, -1, 0};
  // unsigned short debug = get_member_count(sid)-1;
  if( member < 0 || member > SEMSIZE-1) { // SEMSIZE-1 / 12
    fprintf(stderr, "[wait] semaphore member %d out of range\n", member);
    return;
  }

  sem_lock.sem_num = member;
  if((semop(sid, &sem_lock, 1)) == -1) {
    fprintf(stderr, "Wait failed\n");
    exit(1);
  }
}

/// unlocksem()
void signal(int sid, int member) {

  struct sembuf sem_unlock={ member, 1, 0};

  if( member < 0 || member > SEMSIZE-1) { // SEMSIZE-1 / 12
    fprintf(stderr, "[signal] semaphore member %d out of range (max is 12)\n", member);
    return;
  }

  sem_unlock.sem_num = member;
  /* Attempt to unlock the semaphore set */
  if((semop(sid, &sem_unlock, 1)) == -1) {
    fprintf(stderr, "unlocksem failed\n");
    exit(1);
  }
}

/// Marks sempahores for deletion
void removeSem (int semid){
  semctl(semid, 0, IPC_RMID, 0);
  printf("Semaphore set marked for deletion\n");
  fflush(stdout);
}

/// writes in shared memory()
void writeShm(int* segptr, int index, int value) {
  if(index > SEGSIZE - 1){
    fprintf(stderr, "Shared memory : write out of range : %d \n", index);
    exit(1);
  }
  segptr[index] = value;
}

/// reads in shared memory()
int readShm(int* segptr, int index) { //,int id
  if(index > SEGSIZE - 1){
    fprintf(stderr, "Shared memory : read out of range\n");
    exit(1);
  }
  return segptr[index];
}

/// marks shared memory for deletion
void removeShm(int shmid) {
  shmctl(shmid, IPC_RMID, 0);
  printf("Shared memory segment marked for deletion\n");
  fflush(stdout);
}

/// Sends a message queue
void sendMsg(int qid, struct mymsgbuf* qbuf, long type, int speedx, int speedy){
  /* Send message to the queue */
  qbuf->mtype = type;
  qbuf->speedx = speedx;
  qbuf->speedy = speedy;

  // The length is essentially the size of the structure minus sizeof(mtype)
  int length = sizeof(struct mymsgbuf) - sizeof(long);

  if( msgsnd(qid, qbuf, length, 0)  == -1) {
    perror("sending msg failed");
    exit(1); // die("failed to send");
  }
}

/// Retrieves a message from queue
int readMsg( int qid, struct mymsgbuf *qbuf, long type) {
    int result, length;
    // The length is essentially the size of the structure minus sizeof(mtype)
    length = sizeof(struct mymsgbuf) - sizeof(long);

    if( (result = msgrcv( qid, qbuf, length, type,  0)) == -1) {
      perror("receiving msg failed");
      exit(1); // die("failed to receive");
    }
    return result;
}

/// Marks queue for deletion
void removeQueue(int qid){
  /* Remove the queue */
  msgctl(qid, IPC_RMID, 0);
  printf("Message queue marked for deletion\n");
  fflush(stdout);
}


// ------------------------Other functions------------------------------------//

/// Return the position of a given process id in the priority list (shared)
int findInPQ(int* segptr, int p_id){
  for(int i = 0; i < SQUARE_CNT; i++){
    if(readShm(segptr, PRIORITY_LIST_SHM + i) == p_id)
      return i;
  }
  return -1;
}

/*
* Checks in the priority list (shared mem.) if the square managed by process nb id
* has more priority than the one managed by process nb id2
*/
bool thisIDMorePriority(int* segptr, int id, int id2){
  int id_pos  = SQUARE_CNT - 1; // by default
  int id2_pos = SQUARE_CNT - 1; // by default
  for(int i = 0; i < SQUARE_CNT; ++i){
    int curr = readShm(segptr, PRIORITY_LIST_SHM + i);
    if(curr == id2)
      id2_pos = i;
    else if (curr == id)
      id_pos = i;
  }
  return id_pos < id2_pos;
}

/// Checks wether square at (x,y) overlap any other squares
int hasOverlap(int x, int y, int* segptr, int id){
  for(int i = 0; i < SQUARE_CNT ; ++i){
    if(i != id){
      if(y < readShm(segptr, YPOS_SHM + i) + SQUARE_WIDTH
          && y + SQUARE_WIDTH > readShm(segptr, YPOS_SHM + i)
          && x < readShm(segptr, XPOS_SHM + i) + SQUARE_WIDTH
          && x + SQUARE_WIDTH > readShm(segptr, XPOS_SHM + i))
      {
        return i;
      }
    }
  }
  return -1;
}

/// Updates the squares_table positions, thanks to XPOS and YPOS in shared memory
void updateSquaresTable(int* segptr, square* squares_table){
  for(int i = 0; i < SQUARE_CNT; ++i){
    squares_table[i].x = readShm(segptr, XPOS_SHM + i);
    squares_table[i].y = readShm(segptr, YPOS_SHM + i);
  }
}

/*
* Updates the priority list in shared memory, thanks to positions x and y of
* each square stored in shared memory. The priority list stores in ascending order
* of priority the process id of each worker. The Highest square the strongest.
* If two squares have the same height, the most left square get the priority.
*/
void updatePriorityList(int* segptr){
  int currMaxY =-1;
  int currIndex = 0;
  int tmpx[SQUARE_CNT];
  int tmpy[SQUARE_CNT];

  for(int i =0; i < SQUARE_CNT; i++){
      tmpx[i] = readShm(segptr, XPOS_SHM + i);
      tmpy[i] = readShm(segptr, YPOS_SHM + i);
  }

  for(int i = 0; i < SQUARE_CNT; i++){
      currMaxY = -1;
      // if the square is higher than the current, it has more priority
      for(int j = 0; j < SQUARE_CNT; j++){
          if(tmpy[j] > currMaxY){
              currMaxY  = tmpy[j];
              currIndex = j;
          }
          // if the square has the same height and is at the left of the current , it has more priority
          if(tmpy[j] == currMaxY){
              if(tmpx[j] < tmpx[currIndex])
                  currIndex = j;
          }
      } // at the end of this loop, we got the max priority element and its index
      writeShm(segptr, PRIORITY_LIST_SHM + i, currIndex);  // priority[i] = currIndex (an id)
      // we must not take these coordinates into account for the next turn
      tmpx[currIndex] = -1;
      tmpy[currIndex] = -1;
  }
}

/// fills table with zeroes
void resetTable(int table[SIZE_X][SIZE_Y]){
  //Filling the table with zeroes
	for(int i = 0; i < SIZE_X; ++i){
		for(int j = 0; j < SIZE_Y; ++j){
			table[i][j] = 0;
		}
	}
}

/// updates table with info in squares_table
void updateTable(int table[SIZE_X][SIZE_Y], square* squares_table){
  for(int i = 0; i < SQUARE_CNT; i++) {
	  for(int j = 0; j < SQUARE_WIDTH; j++) {
	    for(int k = 0; k < SQUARE_WIDTH; k++) {
	      table[squares_table[i].x + j][squares_table[i].y + k] = squares_table[i].color;
	    }
	  }
	}
}

/// Initializes randomly squares_table
void randomInitialization(square* squares_table){
  int i = 0;
  srand(time(NULL));   // should only be called once
  while(i < SQUARE_CNT){
      squares_table[i].x = rand()%(SIZE_X+1 - SQUARE_WIDTH);
      squares_table[i].y = rand()%(SIZE_X+1 - SQUARE_WIDTH);
        if(!overlapWithPrev(squares_table, i)){
            squares_table[i].speedx = rand()%3 - 1; // -1, 0 or 1
            squares_table[i].speedy = rand()%3 - 1;
            squares_table[i].color = i + 1;
            ++i;
        }
  }
}

/// initializes the squares_table with user inputs
void manualInitialization(square* squares_table){
  int i = 0;
  while(i < SQUARE_CNT){
    printf("Square %d : \n", i);
    do{ printf("\t Enter valid x [0,240]: ");
        scanf("%d", &(squares_table[i].x));

        printf("\t Enter valid y [0,240]: ");
        scanf("%d", &(squares_table[i].y));
    }
    while(squares_table[i].x > 256-SQUARE_WIDTH || squares_table[i].y > 256-SQUARE_WIDTH ||
           squares_table[i].x < 0 || squares_table[i].y < 0);

    if(!overlapWithPrev(squares_table, i)){
      do{ printf("\t Enter speedx [-1,0,1] : ");
          scanf("%d", &(squares_table[i].speedx));
          printf("\t Enter speedy [-1,0,1]: ");
          scanf("%d", &(squares_table[i].speedy));
      }
      while(squares_table[i].speedx > 1 || squares_table[i].speedy > 1 ||
             squares_table[i].speedx < -1 || squares_table[i].speedy < -1);

      squares_table[i].color = i + 1;
      ++i;
    }
    else {
      printf("Overlap with previous square, try again ! \n");
    }
  }
}

/// checks wether the last added square in squares_table has an overlap with one of the prev.
bool overlapWithPrev(square* squares_table, int n){

  if(n == 0)
    return false;

  for(int i = 0; i < n ; ++i){
    if(hasIntersection(squares_table[i], squares_table[n])){
      return true;
    }
  }
  return false;
}

/// Checks wether two squares overlap
bool hasIntersection(square a, square b){
  return (a.y < b.y + SQUARE_WIDTH) && (a.y + SQUARE_WIDTH > b.y) &&
         (a.x < b.x + SQUARE_WIDTH) && (a.x + SQUARE_WIDTH > b.x);
}

/// Display the squares_table
void displaySquares_table(square* squares_table){
  printf("Display of initialization : \n");
  for(int i = 0; i < SQUARE_CNT; ++i){
    printf("squares_table[%d].x = %d \n", i, squares_table[i].x);
    printf("squares_table[%d].y = %d \n", i, squares_table[i].y);
    printf("squares_table[%d].speedx = %d \n", i, squares_table[i].speedx);
    printf("squares_table[%d].speedy = %d \n", i, squares_table[i].speedy);
    printf("squares_table[%d].color = %d \n", i, squares_table[i].color);
    printf("\n \n");
  }
}

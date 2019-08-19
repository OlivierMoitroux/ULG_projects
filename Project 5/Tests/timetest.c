#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdbool.h>

#define handle_error(msg) \
do { perror(msg); exit(EXIT_FAILURE); } while (0)

void test(char **filenames, int nbFiles, void (*op)(int, size_t), int oflag, bool flushCache);

void seq_read_read(int fd, size_t size);
void seq_read_mmap(int fd, size_t size);

void seq_write_write(int fd, size_t size);
void seq_write_mmap(int fd, size_t size);

void rand_read_read(int fd, size_t size);
void rand_read_mmap(int fd, size_t size);

void rand_write_write(int fd, size_t size);
void rand_write_mmap(int fd, size_t size);

#define SIZE_BUF 65536

// free
// sync; echo 3 | sudo tee /proc/sys/vm/drop_caches;
// system("free && sync && echo 3 > /proc/sys/vm/drop_caches && free");

int main(int argc, char *args[])
{

    if (argc != 2){
        printf("Expecting one argument\n");
        return -1;
    }

    system("sync && echo 3 > /proc/sys/vm/drop_caches");

    bool flushCache = true;
    int fd;
    uint64_t size;

    struct stat sb;

    char* seqFilenames[] = {"s4.txt"};
    int nbSeqFilenames = sizeof(seqFilenames) / sizeof(char *);

    char* randFilenames[] = {"r4.txt"};
    int nbRandFilenames = sizeof(randFilenames) / sizeof(char *);

    if (strcmp(args[1], "test") == 0) {

        printf("\n\n");

        /* seq_read_read */
        printf("seq_read_read");
        test(seqFilenames, nbSeqFilenames, seq_read_read, O_RDONLY, flushCache);
        //printf("]\n\n");

        // system("sync && echo 3 > /proc/sys/vm/drop_caches");

        /* seq_read_mmap */
        /*
        printf("seq_read_mmap = [");
        test(seqFilenames, nbSeqFilenames, seq_read_mmap, O_RDONLY, flushCache);
        printf("]\n\n");

        system("sync && echo 3 > /proc/sys/vm/drop_caches");
        */

        /* seq_write_write */
        /*
        printf("seq_write_write = [");
        test(seqFilenames, nbSeqFilenames, seq_write_write, O_WRONLY, flushCache);
        printf("]\n\n");

        system("sync && echo 3 > /proc/sys/vm/drop_caches");
        */
        /* seq_write_mmap */
        /*
        printf("seq_write_mmap = [");
        test(seqFilenames, nbSeqFilenames, seq_write_mmap, O_RDWR, flushCache);
        printf("]\n\n");

        system("sync && echo 3 > /proc/sys/vm/drop_caches");
        */
        /* rand_read_read */
        /*
        printf("rand_read_read = [");
        test(randFilenames, nbRandFilenames, rand_read_read, O_RDONLY, flushCache);
        printf("]\n\n");

        system("sync && echo 3 > /proc/sys/vm/drop_caches");
        */
        /* rand_read_mmap */
        /*
        printf("rand_read_mmap = [");
        test(randFilenames, nbRandFilenames, rand_read_mmap, O_RDONLY, flushCache);
        printf("]\n\n");

        system("sync && echo 3 > /proc/sys/vm/drop_caches");
        */
        /* rand_write_write */
        /*
        printf("rand_write_write = [");
        test(randFilenames, nbRandFilenames, rand_write_write, O_WRONLY, flushCache);
        printf("]\n\n");

        system("sync && echo 3 > /proc/sys/vm/drop_caches");
        */
        /* rand_write_mmap */
        /*
        printf("rand_write_mmap = [");
        test(randFilenames, nbRandFilenames, rand_write_mmap, O_RDWR, flushCache);
        printf("]\n\n");
        */

    }

    /* repetitive OPENING_CLOSING + FULL READ of a given file test */

    else if (strcmp(args[1], "repetitiveopen") == 0){
        int nbIter = 20;
        int fd = open("4.pdf", O_RDONLY);
        fstat(fd, &sb);
        int size = (uint64_t)sb.st_size;
        clock_t start;

        printf("mmap read %d times the same file:\n", nbIter);
        for (int i = 0; i < nbIter; i++) {
            start = clock();
            fd = open("4.pdf", O_RDONLY);
            seq_read_mmap(fd, size);
            close(fd);
            printf("%lf ", ((double)(clock() - start)) / CLOCKS_PER_SEC);
            if(flushCache)
    			         system("sync && echo 3 > /proc/sys/vm/drop_caches");
        }

        printf("\nread() read %d times the same file:\n", nbIter);
        system("sync && echo 3 > /proc/sys/vm/drop_caches");
        for (int i = 0; i < nbIter; i++) {
            start = clock();
            fd = open("4.pdf", O_RDONLY);
            seq_read_read(fd, size);
            close(fd);
            printf("%lf ", ((double)(clock() - start)) / CLOCKS_PER_SEC);
            if(flushCache)
                system("sync && echo 3 > /proc/sys/vm/drop_caches");
        }
        printf("\n");
    }

    else {
        printf("USAGE: sudo ./debug <filesize><readsize><accesspattern><repetitiveopen>\n");
        return -1;
    }
}



void test(char **filenames, int nbFiles, void (*op)(int, size_t), int oflag, bool flushCache) {

    int fd;
    struct stat sb;
    uint64_t size;
    clock_t start;
    double meanTime, totTime;
    const int N = 1;

    for (int i = 0; i < nbFiles; i++) {

        totTime = 0;

        for (int j = 0; j < N; j++) {
            fd = open(filenames[i], oflag);

            fstat(fd, &sb);
            size = (uint64_t)sb.st_size;

            start = clock();

            op(fd, size);

            totTime += ((double)(clock() - start)) / CLOCKS_PER_SEC;

            close(fd);
            if(flushCache)
                system("sync && echo 3 > /proc/sys/vm/drop_caches");
        }

        meanTime = totTime / N;

        //printf("%lu %lf;\n", size, meanTime);
    }
}



/* OPERATIONS --------------------------------------------------------------- */



void seq_read_read(int fd, size_t size) {

    char c;
    size_t count = SIZE_BUF;
    char *buf = malloc(count); // void*

    ssize_t nbread;
    if (!buf)
        handle_error("malloc");

    for(uint64_t i = 0; i < size / count + 1; i++)
    {
        nbread = read(fd, buf, count);
        if (nbread < 0)
            handle_error("seq_read_read");

        for (int j = 0; j < nbread; j++) {
            c = buf[i];
        }
    }

}



void seq_read_mmap(int fd, size_t size) {

    char *memblock;
    char c;

    memblock = mmap(NULL, size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (memblock == MAP_FAILED) handle_error("seq_read_mmap");

    for(uint64_t i = 0; i < size; i++)
    {
        c = memblock[i];
    }

    munmap(memblock, size);

}



void seq_write_write(int fd, size_t size) {

    char c = 'k';
    size_t count = SIZE_BUF;
    char *buf = malloc(count); // void*

    ssize_t nbwrite = count;
    if (!buf)
        handle_error("malloc");

    for(uint64_t i = 0; i < size / count; i++)
    {

        for (int j = 0; j < nbwrite; j++) {
            buf[i] = c;
        }

        if (write(fd, buf, nbwrite) < 0)
            handle_error("seq_write_write");
    }

    nbwrite = size % count;
    for (uint64_t i = 0; i < nbwrite; i++) {
        buf[i] = c;
    }

    if (write(fd, buf, nbwrite) < 0)
        handle_error("seq_write_write_last");

}



void seq_write_mmap(int fd, size_t size) {

    char *memblock;
    char c = 'k';

    memblock = mmap(NULL, size, PROT_WRITE, MAP_PRIVATE, fd, 0);
    if (memblock == MAP_FAILED) handle_error("seq_write_mmap");

    for(uint64_t i = 0; i < size; i++)
    {
        memblock[i] = c;
    }

    munmap(memblock, size);

}



void rand_read_read(int fd, size_t size) {

    char c;
    int n;
    size_t count = SIZE_BUF;
    char *buf = malloc(count); // void*
    if (!buf)
        handle_error("malloc");
    srand(time(NULL));

    for(uint64_t i = 0; i < size; i++)
    {
        n = rand() % size;
        if (lseek(fd, n, SEEK_SET) < 0)
            handle_error("lseek");
        if (read(fd, buf, count) < 0)
            handle_error("rand_read_read");
        c = buf[0];
    }
}



void rand_read_mmap(int fd, size_t size) {

    char *memblock;
    char c;

    memblock = mmap(NULL, size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (memblock == MAP_FAILED) handle_error("rand_read_mmap");
    srand(time(NULL));

    for(uint64_t i = 0; i < size; i++)
    {
        c = memblock[rand() % size];
    }

    munmap(memblock, size);
}



void rand_write_write(int fd, size_t size) {

    char c = 'k';
    int n;
    size_t count = 1;
    char *buf = malloc(count); // void*
    if (!buf)
        handle_error("malloc");
    srand(time(NULL));

    for(uint64_t i = 0; i < size; i++)
    {
        n = rand() % size;
        if (lseek(fd, n, SEEK_SET) < 0)
            handle_error("lseek");
        buf[0] = c;
        if (write(fd, buf, count) < 0)
            handle_error("rand_write_write");

    }
}



void rand_write_mmap(int fd, size_t size) {

    char *memblock;
    char c = 'k';

    memblock = mmap(NULL, size, PROT_WRITE, MAP_PRIVATE, fd, 0);
    if (memblock == MAP_FAILED) handle_error("rand_write_mmap");
    srand(time(NULL));

    for(uint64_t i = 0; i < size; i++)
    {
        memblock[rand() % size] = c;
    }

    munmap(memblock, size);
}

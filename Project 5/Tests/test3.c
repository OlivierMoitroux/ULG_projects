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

void rand_read(int fd, size_t size);
void rand_mmap(int fd, size_t size);
void seq_read(int fd, size_t size);
void seq_mmap(int fd, size_t size);
double timeexec(void (*fct)(int, size_t), int fd, size_t size);


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

	/* -- file size FULL READING test -- */
	if (strcmp(args[1], "filesize") == 0) {

		char* filenames[] = {"1.pdf","2.pdf","3.pdf", "4.pdf", "5.pdf"};

        /* mmap */
        printf("sequence read with mmap on different file sizes (caching = %s):\n", (flushCache)?"true":"false");

		for (int i = 0; i < sizeof(filenames) / sizeof(char *); i++) {

			fd = open(filenames[i], O_RDONLY);

			fstat(fd, &sb);
			size = (uint64_t)sb.st_size;

			printf("seq_mmap: %lu %lf \n", size, timeexec(seq_mmap, fd, size));

			close(fd);
            if(flushCache)
			         system("sync && echo 3 > /proc/sys/vm/drop_caches");
        }

        system("sync && echo 3 > /proc/sys/vm/drop_caches");

        /*read */
        for (int i = 0; i < sizeof(filenames) / sizeof(char *); i++) {

            fd = open(filenames[i], O_RDONLY);

			printf("seq_read: %lu %lf \n", size, timeexec(seq_read, fd, size));

			close(fd);
            if(flushCache)
			         system("sync && echo 3 > /proc/sys/vm/drop_caches");
        }
	}


    /* -- PARTIAL READ length in a fixed size file -- */

    else if ((strcmp(args[1], "readsize") == 0)) {

		char filename[] = "4.pdf";
		fd = open(filename, O_RDONLY);
		fstat(fd, &sb);
		size = (uint64_t)sb.st_size;
		close(fd);
		int N = 10;
		size_t readsizes[N];
		for (int i = 0; i < N ; i++)
			readsizes[i] = (i + 1) * (size / N+1);

        printf("seq_mmap (caching = %s):\n", (flushCache)?"true":"false");
		for (int i = 0; i < sizeof(readsizes) / sizeof(size_t); i++) {

			fd = open(filename, O_RDONLY);

			printf("%lu %lf \n", readsizes[i], timeexec(seq_mmap, fd, readsizes[i]));
            // printf("%lf ", timeexec(seq_read, fd, readsizes[i]));

			close(fd);
            if(flushCache)
			         system("sync && echo 3 > /proc/sys/vm/drop_caches");
        }

        system("sync && echo 3 > /proc/sys/vm/drop_caches");

        printf("seq_read (caching = %s):\n", (flushCache)?"true":"false");
        for (int i = 0; i < sizeof(readsizes) / sizeof(size_t); i++) {
			fd = open(filename, O_RDONLY);

			printf("%lu %lf \n", readsizes[i], timeexec(seq_read, fd, readsizes[i]));
            // printf("%lf ", timeexec(seq_read, fd, readsizes[i]));

			close(fd);
            if(flushCache)
			         system("sync && echo 3 > /proc/sys/vm/drop_caches");
		}
        printf("\n");
	}

    /* READING PATTERN TEST IN A FIXED-SIZE FILE */

    else if (strcmp(args[1], "accesspattern") == 0) {

		char filename[] = "4.pdf";
		fd = open(filename, O_RDONLY);
		fstat(fd, &sb);
		size = (uint64_t)sb.st_size;
		close(fd);
        int nbIter = 10;

        printf("seq_mmap (caching = %s): ", (flushCache)?"true":"false");
		for (int i = 0; i < nbIter; i++) {

			fd = open(filename, O_RDONLY);

			printf("%lf ", timeexec(seq_mmap, fd, size));

			close(fd);
            if(flushCache)
			         system("sync && echo 3 > /proc/sys/vm/drop_caches");
         }
         system("sync && echo 3 > /proc/sys/vm/drop_caches");
         printf("\nseq_read (caching = %s): ", (flushCache)?"true":"false");
         for (int i = 0; i < nbIter; i++) {

			fd = open(filename, O_RDONLY);

			printf("%lf ", timeexec(seq_read, fd, size));

			close(fd);
            if(flushCache)
			         system("sync && echo 3 > /proc/sys/vm/drop_caches");
        }

        system("sync && echo 3 > /proc/sys/vm/drop_caches");
        printf("\nrand_mmap (caching = %s): ", (flushCache)?"true":"false");
        for (int i = 0; i < nbIter; i++) {
			fd = open(filename, O_RDONLY);

			printf("%lf ", timeexec(rand_mmap, fd, size));

			close(fd);
            if(flushCache)
			         system("sync && echo 3 > /proc/sys/vm/drop_caches");
         }

         system("sync && echo 3 > /proc/sys/vm/drop_caches");
         printf("\nrand_read (caching = %s): ", (flushCache)?"true":"false");
         for (int i = 0; i < nbIter; i++) {
			fd = open(filename, O_RDONLY);

			printf("%lf ", timeexec(rand_read, fd, size));

			close(fd);
            if(flushCache)
			         system("sync && echo 3 > /proc/sys/vm/drop_caches");
         }
         printf("\n");

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
                seq_mmap(fd, size);
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
            seq_read(fd, size);
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

double timeexec(void (*fct)(int, size_t), int fd, size_t size) {

	clock_t start = clock();

	fct(fd, size);

	return ((double)(clock() - start)) / CLOCKS_PER_SEC;
}

void seq_mmap(int fd, size_t size) {

	char *memblock;
	char c;

	memblock = mmap(NULL, size, PROT_WRITE, MAP_PRIVATE, fd, 0);
	if (memblock == MAP_FAILED) handle_error("mmap");

	for(uint64_t i = 0; i < size; i++)
	{
		c = memblock[i];
	}

	munmap(memblock, size);

}

void seq_read(int fd, size_t size) {

	char c;
	size_t count = 65536; //64K
	char *buf = malloc(count); // void*

	ssize_t nbread;
	if (!buf)
		handle_error("malloc");

	for(uint64_t i = 0; i < size / count + 1; i++)
	{
		nbread = read(fd, buf, count);
		if (nbread < 0)
			handle_error("read");

		for (int j = 0; j < nbread; j++) {
			c = buf[i];
		}
	}

}

void rand_mmap(int fd, size_t size) {

	char *memblock;
	char c;

	memblock = mmap(NULL, size, PROT_WRITE, MAP_PRIVATE, fd, 0);
	if (memblock == MAP_FAILED) handle_error("mmap");
	srand(time(NULL));

	for(uint64_t i = 0; i < size; i++)
	{
		c = memblock[rand() % size];
	}

	munmap(memblock, size);
}

void rand_read(int fd, size_t size) {

	char c;
	int n;
	size_t count = 65536; //64K
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
			handle_error("read");
		c = buf[0];
	}
}


/*
   const char *memblock;
   int fd;
   struct stat sb;

   fd = open(argv[1], O_RDONLY);
   fstat(fd, &sb);
   printf("Size: %lu\n", (uint64_t)sb.st_size);

   memblock = mmap(NULL, sb.st_size, PROT_WRITE, MAP_PRIVATE, fd, 0);
   if (memblock == MAP_FAILED) handle_error("mmap");

   for(uint64_t i = 0; i < 10; i++)
   {
     printf("[%lu]=%X ", i, memblock[i]);
   }
   printf("\n");
   return 0;
}

*/

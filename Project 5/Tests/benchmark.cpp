#include <iostream>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/mman.h>
#include <sched.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <semaphore.h>
#include <syscall.h>

int g_type;
int g_delay;

void *workerDisturber (void *param)
{
  int p1,p2,p3,p4,p5;
  p1=p2=p3=p4=p5=0;
  while(true)
  {

    for(int i=0;i<500000;i++)
    {
			p1=p3++;
			p3=p2++;
			p4=p1++;
			p2=p5++;
			p5=p4++;
    }
    if(g_delay>0)
      usleep(g_delay);
  }
  return NULL;
}

void *workerMMAP (void *parameter)
{
	int *num=(int *)parameter;
	printf("Start thread %i\n",*num);
	int cpu=(*num)%8;

	cpu_set_t cpuset;
	CPU_ZERO(&cpuset);
	CPU_SET(cpu, &cpuset);

	sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);

	nice(-10);

  int p1,p2,p3,p4,p5;
  p1=p2=p3=p4=p5=0;
  unsigned int sizesmem[3]={ 40960, 51200, 71680};
  for(int rep=0;rep<500000;rep++)
  {
  	if((rep%100)==0)
    	sched_yield();
    void *dir=mmap(NULL, sizesmem[rep%3], PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_SHARED, -1, 0);
    for(int i=0;i<10000;i++)
    {
			p1=p3++;
			p3=p2++;
			p4=p1++;
			p2=p5++;
			p5=p4++;
    }
    if(dir!=MAP_FAILED)
			munmap(dir, sizesmem[rep%3]);
    if(g_delay>0)
      usleep(g_delay);

  }
  return NULL;
}

int main(int argc, char **argv)
{
    long mtime, seconds, useconds;
    struct timeval start, end;

    if(argc<4)
    {
      printf("Usage mmap type n_workers delay\n");
      return 0;
    }
    g_type=atoi(argv[1]);
    int num_threads=atoi(argv[2]);
    g_delay=atoi(argv[3]);
    printf("Num workers %i\n", num_threads);

    pthread_t *idHilo=(pthread_t *)malloc(sizeof(pthread_t)*num_threads);

    gettimeofday(&start, NULL);

    printf("Threads launched\n");
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    for(int i=0;i<num_threads;i++)
    {
    	int *num=(int*)malloc(sizeof(int));
    	*num=i;
      if(g_type==0)
				pthread_create (&idHilo[i], &attr, workerMMAP, num);
      else
				pthread_create (&idHilo[i], &attr, workerDisturber, num);

    }
    void *res;
    for(int i=0;i<num_threads;i++)
    {
      pthread_join(idHilo[i], &res);
    }
    gettimeofday(&end, NULL);

    seconds  = end.tv_sec  - start.tv_sec;
    useconds = end.tv_usec - start.tv_usec;

    mtime = ((seconds) * 1000 + useconds/1000.0) + 0.5;

    printf("Elapsed time: %ld milliseconds\n", mtime);
    printf("Threads ends\n");
    free(idHilo);
    return 0;
}

// g++  -lpthread –o mmap file.cpp
// ./mmap 0 [Number of threads] 0


/**-----------------------------------------------------------------------------
 *                 2nd Project O.S. : Simple shell
 *                 *******************************
 *
 * @Author : Compagnie Romain, Moitroux Olivier
 *----------------------------------------------------------------------------*/

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

// Relative to process management
#include <unistd.h>
#include <sys/wait.h>

// sys IP
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <arpa/inet.h>

/**
 * parseLine() parses and splits the tokens from the line string
 * @param tokens : empty 2d-array to store the cmds
 * @param line : the line input in the shell by the user
 * @return Fills the tokens array and returns 0 in case of success, -1 otherwise
 */
static int parseLine(char *tokens[], char *line);

/**
 * setLine() replaces the variables in str by their value and stores the result
 * in line
 * @param line :
 * @param n : the current size of the memory allocated for line
 * @param str : the str input in the shell by the user
 * @return Fills line with variables replaced by their value and returns 0 in
 * case of success, -1 otherwise
 */
static int setLine(char **line, size_t *n, char *str);

/**
 * setVar() sets a variable with the given value. The variable is overwritten if
 * it exists or created, if enough space is availble
 * @param name : the name of the variable
 * @param value : the value of the variable
 * @return : 0 in case of success, -1 otherwise
 */
static int setVar(char *name, char *value);

/**
 * max() returns the max of its 2 arguments.
 */
static int max(int a, int b);

/**
 * exeLine() executes cmds found in the vector of arguments
 * @param args : 2d-array of arguments
 * @param ret : address of variable to store the return value
 * @return Sets ret to the return value and returns 0 in case of success, -2 if
 * exit cmd input or -1 otherwise
 */
static int exeLine(char *args[], int *retVal, pid_t *retPid);

/**
 * bltIn_cd() changes working directory
 * @param args : 2d-array that stores the input cmds
 * @return  0 in case of success, -1 otherwise
 */
static int bltIn_cd(char *args[]);

/**
 * bltIn_help() displays help message
 * @param args :  2d-array that stores the input cmds
 * @return 0 in case of success, -1 otherwise
 */
static int bltIn_help(char *args[]);

/**
 * bltIn_sys() manage call to built-in sys commands
 * @param args :  2d-array that stores the input cmds
 * @return 0 in case of success, -1 otherwise
 */
static int bltIn_sys(char *args[]);

/**
 * bltIn_sysHostname() display hostname
 * @param args :  2d-array that stores the input cmds
 * @return 0 in case of success, -1 otherwise
 */
static int bltIn_sysHostname(char *args[]);

/**
 * bltIn_sysCPU() manage call to built-in sys cpu commands
 * @param args :  2d-array that stores the input cmds
 * @return 0 in case of success, -1 otherwise
 */
static int bltIn_sysCpu(char *args[]);

/**
 * bltIn_sysIP() : display the ip and the mask of the interface input. If 2 ip
 *                 addr are entered, change the ip and the mask of the interface
 * @param args :  2d-array that stores the input cmds
 * @return 0 in case of success, -1 otherwise
 */
static int bltIn_sysIp(char *args[]);

/**
 * disp_cpu_model() display the cpu model
 * @param args :  2d-array that stores the input cmds
 * @return 0 in case of success, -1 otherwise
 */
static int disp_cpu_model();

/**
 * disp_cpu_freq() display the frequency of the cpu no input (in MHz)
 * @param args :  2d-array that stores the input cmds
 * @return 0 in case of success, -1 otherwise
 */
static int disp_cpu_freq(int cpuNo);

/**
 * set_cpu_freq() set the frequency of the processor no input
 * @param cpuNo   :  the cpu no input
 * @param freq2Set :  the frequency to set on the cpu input
 * @return 0 in case of success, -1 otherwise
 */
static int set_cpu_freq(char *cpuNo, char *freq2Set);


#define MAX_CHAR_ARG  255
#define MAX_CHAR_VAR_NAME 63

typedef struct fct_t {
	int (*fctPtr)(char **);
	char name[MAX_CHAR_ARG + 1];
} fct;

#define NB_BLT_IN_CMD 3

static const fct bltInCmd[NB_BLT_IN_CMD] = {
    {bltIn_cd, "cd"},
    {bltIn_help, "help"},
    {bltIn_sys, "sys"}
};


static const char CMD_NAME_EXIT[] = "exit"; // Exit command name

typedef struct var_t {
	char name[MAX_CHAR_VAR_NAME + 1];
	char value[MAX_CHAR_ARG + 1];
} var;

#define MAX_NB_VAR 64

var variables[MAX_NB_VAR];

int nbVar = 0;

#define MAX_ARGS      255
#define SIZE_STR_BUF 12

/**
 * Simple shell main function
 */
int main() {

	char *str = NULL, *line = NULL; // for getline (should be freeable)
	size_t strSize = 0, lineSize = 0;
    char *args[MAX_ARGS + 1];
    char strBuf[SIZE_STR_BUF];
	int status, ret;
    pid_t pid;

    // Set built in variables
    setVar("?", "0");
    setVar("!", "0");

	while (true) {

		// Start line
		printf("> ");
		fflush(stdout);

		// Read line (exit if error or EOF)
		if (getline(&str, &strSize, stdin) < 0) {
			free(str); // str must be freed even if error
			if (line != NULL)
				free(line); // TO DO: frees not necessary;
			exit(EXIT_SUCCESS);
		}

		// If return, new line
		if (strcmp(str, "\n") == 0)
			continue;

		// Replace variables
		if (setLine(&line, &lineSize, str) < 0) {
			free(str);
			exit(EXIT_FAILURE);
		}

		// Parse line (continue if error)
		if ((ret = parseLine(args, line)) < 0)
			continue;

		// Variable definition
		if (ret == 1)
			ret = setVar(args[0], args[1]);

        // Execute cmd
        else {
    		// Execute line (exit if error or exit code)
    		status = exeLine(args, &ret, &pid);
    		if (status < 0) {
    			free(line);
    			// Error
    			if (status == -1)
    				exit(EXIT_FAILURE);
    			// Exit code
    			if (status == -2)
    				exit(EXIT_SUCCESS);
    		}
        }

        // Update built in variables
        snprintf(strBuf, SIZE_STR_BUF, "%d", ret);
        setVar("?", strBuf);
        snprintf(strBuf, SIZE_STR_BUF, "%u", (unsigned int)pid);
        setVar("!", strBuf);

		// Print return value
		printf("\n%d", ret);
	}
}


#define SIZE_LINE_INIT 128

int setLine(char **line, size_t *n, char *str) {

	char *ptrStr = str, *strToAdd, *varName, *prevLine, delim[] = " \n\"";
	int tmpSize = 0, len, varNameLen;

    if (*line == NULL) {
        if ((*line = malloc(SIZE_LINE_INIT * sizeof(char))) == NULL) {
            fprintf(stderr, "[setLine()] Error malloc\n");
            return -1;
        }
		*n = SIZE_LINE_INIT * sizeof(char);
    }
    (*line)[0] = '\0';

	while (*ptrStr != '\0') {

		switch (*ptrStr) {

			// Variable check
			case '$':

				// Temporary string to add
				strToAdd = ptrStr;
				varName = ptrStr + 1;

				switch (*varName) {
					case '{':
						varName++;
						varNameLen = strcspn(varName, "}");
						len = varNameLen + 2;
                        // len += strspn((ptrStr + len), "}");
                        len += (*(ptrStr + len) == '}') ? 1 : 0;
						break;
					default:
						varNameLen = strcspn(varName, delim);
						len = varNameLen + 1;
						break;
				}

				// Next token
				ptrStr += len;

				// Search variable
				for (int i = 0; i < nbVar; i++) {
					if (strncmp(varName, variables[i].name, varNameLen) == 0
                        && variables[i].name[varNameLen] == '\0') {

						strToAdd = variables[i].value;
						len = strlen(variables[i].value);
						break;
					}
				}
				break;

			// Next part of string
			default:

				// String to add
				strToAdd = ptrStr;
				len = strcspn(ptrStr, "$");
				// Next string
				ptrStr += len;
				break;
		}

		// Update size of line in creation
		tmpSize += len;

		// Update space size of line if needed
		if ((tmpSize + 1) * sizeof(char) > *n) {

			// New size
			*n = max((tmpSize + 1) * sizeof(char), 2 * *n);
			// Reallocate
			prevLine = *line; // Save previous pointer
			if ((*line = realloc(*line, *n)) == NULL) {
				if (prevLine != NULL)
					free(prevLine);
                *n = 0;
				fprintf(stderr, "[setLine()] realloc failed\n");
				return -1;
			}
		}

		// Add string
		strncat(*line, strToAdd, len);
	}

    return 0;
}


int max(int a, int b) {
	return a > b ? a : b;
}


int parseLine(char *tokens[], char *line) {

	char *ptrStr = line;
	int curArg = 0;
	bool setVariable = false;
	char delim[] = " \n";
	char *token;

    // Characters to ignore
    ptrStr += strspn(ptrStr, delim);

	while (*ptrStr != '\0' && curArg < MAX_ARGS) {

		switch (*ptrStr) {

			// New argument between quotes
			case '\"':

				ptrStr++;
				// Find end of arg
				token = strsep(&ptrStr, "\"");
				// Set arg
				tokens[curArg] = token;
				curArg++;
				break;

			// New argument
			default:

				// Find end of arg
				// Variable definition
				if (curArg == 0 && strchr(ptrStr, '=') != NULL) {
					token = strsep(&ptrStr, "=");
					setVariable = true;
				}
				// Standard argument
				else
					token = strsep(&ptrStr, delim);
				// Set arg
				tokens[curArg] = token;
				curArg++;
				break;
		}

		// End of line reached
		if (ptrStr == NULL)
			break;

		// Characters to ignore
		ptrStr += strspn(ptrStr, delim);
	}

	// List of tokens terminated by NULL pointer
	tokens[curArg] = (char*) NULL;

	if (setVariable)
		return 1; // Variable set code
	return 0;
}


#define MAX_CHAR_LOC  255

int exeLine(char *args[], int *retVal, pid_t *retPid) {

	// No command input
	if(args[0] == NULL){
		return 0;
	}

	// Exit command check
	if (strcmp(args[0], CMD_NAME_EXIT) == 0)
		return -2; // exit code

	// Built in command check
	for (int i = 0; i < NB_BLT_IN_CMD; i++) {
		if (strcmp(args[0], bltInCmd[i].name) == 0) {
			*retVal = (*bltInCmd[i].fctPtr)(args);
			return 0;
		}
	}

	// Start new process
	pid_t pid = fork();
	int childStatus;

	// Fork error
	if (pid < 0) {
		perror("[fork()] Process creation failed");
		return -1;
	}

	// Child process
	if (pid == 0) {

		char *token;
		char path[MAX_CHAR_LOC + MAX_CHAR_ARG + 2], cmdName[MAX_CHAR_ARG + 1];
		const char delim[] = ":"; // Paths delimiter
		// Get path variable
		char *paths = strdup(getenv("PATH")); // getenv return copied

		// If command path was entered, execute
		execv(args[0], args);

		// Save command name
		strncpy(cmdName, args[0], MAX_CHAR_ARG);

		// Get the first location
		token = strtok(paths, delim);

		// Walk through locations and try execution
		while (token != NULL) {
			// Copy location to path
			strncpy(path, token, MAX_CHAR_LOC);
			// Add separator
			strcat(path, "/");
			// Append filename to the path
			strncat(path, cmdName, MAX_CHAR_ARG);
			// Update first argument
			args[0] = path;

			// Try to execute
			execv(path, args);

			// Next location
			token = strtok(NULL, delim);
		}

		// If execv returns, command not found
		fprintf(stderr, "%s: command not found\n", cmdName);
		exit(EXIT_SUCCESS);

	}
	// Father process
	else {
		// Wait for the child to finish its execution
        do {
            waitpid(pid, &childStatus, WUNTRACED);
            // Passing addr of 'childStatus' to get info the child's status
        } while (!WIFEXITED(childStatus) && !WIFSIGNALED(childStatus));
    }

	// Set command return value
	*retVal = WEXITSTATUS(childStatus);
    *retPid = pid;

	return 0;
}


int setVar(char *name, char *value) {

    if (name == NULL || value == NULL) {
        fprintf(stderr, "setVar : name and value expected\n");
        return -1;
    }

	// Search if existing variable
	for (int i = 0; i < nbVar; i++) {
		if (strcmp(name, variables[i].name) == 0) {
			strncpy(variables[i].value, value, MAX_CHAR_ARG);
			return 0;
		}
	}
	// Number of variables exceeded
	if (nbVar == MAX_NB_VAR) {
		fprintf(stderr, "All variable slots used, restart shell to free\n");
		return -1;
	}
	// New variable
	strncpy(variables[nbVar].name, name, MAX_CHAR_VAR_NAME);
	strncpy(variables[nbVar].value, value, MAX_CHAR_ARG);
	nbVar++;
    return 0;
}

/** ---------------------------------------------------------------------------*
 *                              built-in functions                             *
 *                              ******************                             *
 *  --------------------------------------------------------------------------*/

int bltIn_cd(char *args[]) {
	// Arg check
	if (args[1] == NULL) {
		// Go back home
		if (chdir(getenv("HOME")) < 0) {
			perror("cd failed back home\n");
			return -1;
		}
	}
	// Check error
	else if (chdir(args[1]) < 0) {
		fprintf(stderr, "cd: %s: ", args[1]);
		perror("");
		return -1;
	}
	return 0;
}


int bltIn_help(char *args[]) {
	printf("By Compagnie Romain & Moitroux Olivier\n");
	printf("Type man to get infos about a command.\n");
	return 0;
}

#define NB_BLT_IN_CMD_SYS 3

static const fct bltInCmdSys[NB_BLT_IN_CMD_SYS] = {
    {bltIn_sysHostname, "hostname"},
    {bltIn_sysCpu, "cpu"},
    {bltIn_sysIp, "ip"}
};


int bltIn_sys(char *args[]) {
    // Arg check
    if (args[1] == NULL) {
        fprintf(stderr,"sys expects an argument\n\n");
        printf("USAGE :\n"
               " * sys hostname \n"
               " * sys cpu model \n"
               " * sys cpu freq N / sys cpu freq N X \n"
               " * sys ip addr DEV / sys ip addr DEV IP MASK\n");
        return -1;
    }
    // Arg 1 check
    for (int i = 0; i < NB_BLT_IN_CMD_SYS; i++) {
        if (strcmp(args[1], bltInCmdSys[i].name) == 0)
            return (*bltInCmdSys[i].fctPtr)(args);
    }
    // Unknowkn first argument
    fprintf(stderr, "sys: unknown argument %s", args[1]);
    return -1;
}


int bltIn_sysHostname(char *args[]) {

    FILE *fp = fopen("/proc/sys/kernel/hostname", "r");
    if (fp == NULL) {
        fprintf(stderr,"Can't open file\n");
        return -1;
    }

    int c; // char cast to int
    while ((c = fgetc(fp)) != EOF)
        putchar(c);
    fclose(fp);
    return 0;
}


int bltIn_sysCpu(char *args[]) {

    // Check args
    if (args[2] == NULL) {
        fprintf(stderr, "sys cpu expects an argument\n");
        printf("USAGE :\n"
               "* sys cpu model\n"
               "* sys cpu freq\n");
        return -1;
    }

    // sys cpu model
    if (strcmp(args[2], "model") == 0)
        return disp_cpu_model();

    // sys cpu freq
    if (strcmp(args[2], "freq") == 0) {

        if (args[3] == NULL) {
            fprintf(stderr,"sys cpu freq: expects the number of the processor as argument\n");
            printf("USAGE : sys cpu freq N\n");
            return -1;
        }

        // sys cpu freq N
        if (args[4] == NULL)
            return disp_cpu_freq(atoi(args[3]));

        // sys cpu freq N X
        return set_cpu_freq(args[3], args[4]);

    }

    fprintf(stderr, "sys cpu %s not defined\n", args[2]);
    return -1;
}


int disp_cpu_model() {

    // Open file for reading
    FILE *fp = fopen("/proc/cpuinfo", "r");
    if (fp == NULL){
        fprintf(stderr, "Error opening file\n");
        return -1;
    }
    // Find the correct field
    char str[256];
    char modelName[] = "model name\t:";
    int modelNameLen = strlen(modelName);

    while (fgets(str, 256, fp) != NULL) {
        if (strncmp(str, modelName, modelNameLen) == 0) {
            // Display cpu model
            printf("%s", str + modelNameLen + 1); // + 1 for beguining space
            fclose(fp);
            return 0;
        }
    }

    fclose(fp);
    // Not found
    return -1;
}


int disp_cpu_freq(int cpuNo){

    // Opening file for reading
    FILE *fp = fopen("/proc/cpuinfo", "r");
    if (fp == NULL){
        fprintf(stderr, "Error opening file\n");
        return -1;
    }

    char str[256];
    char cpuMHz[]  = "cpu MHz";    char proc[]  = "processor\t:";
    int  cpuMHzLen = strlen(cpuMHz);  int  procLen = strlen(proc);
    int currProc = 0;

    while (fgets(str, 256, fp) != NULL) {

        if (strncmp(str, proc, procLen) == 0){
            currProc = atoi(str+procLen);
        }

        if (currProc < cpuNo)
            continue;

        if (currProc > cpuNo)
            break; // field CPU MHz not found, stop reading

        if (strncmp(str, cpuMHz, cpuMHzLen) == 0){

            char *col;
            col = strchr(str,':');
            if (col != NULL) {
                int pos = col-str+2;
                printf("%s MHz\n", strtok(str+pos, "\n"));
            }
            fclose(fp);
            return 0;
        }

    }
    // Alternative : search in /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq
    // (sudo is then required)
    fprintf(stderr,"Wrong processor number or miss-formated cpuinfo file\n");
    fclose(fp);
    return -1;
}


#define MAX_SIZE_PATH 256

int set_cpu_freq(char *cpuNo, char *freq2Set) {

    char str[255];
    bool uSpaceFnd = false;

    char path[MAX_SIZE_PATH];
    snprintf(path, MAX_SIZE_PATH,
             "/sys/devices/system/cpu/cpu%s/cpufreq/scaling_available_governors", cpuNo);

    FILE* fp = fopen(path, "r");
    if (fp== NULL) {
        fprintf(stderr, "Error opening scaling_available_governors file\n");
        return -1;
    }

    if(fgets(str,255, fp) == NULL){
        fprintf(stderr, "error reading file\n");
        fclose(fp);
        return -1;
    }

    fclose(fp);

    char *gov = strtok(str, " ");

    // Walk through other subStr
    for ( ; gov != NULL && !uSpaceFnd; gov = strtok(NULL, " \n") ) {
        if(strcmp(gov, "userspace") == 0)
            uSpaceFnd = true;
    }

    if(!uSpaceFnd) {
        fprintf(stderr, "sys cpu freq : userspace governor not available\n");
        printf("Please disable the driver intel_pstate in your kernel boot line\n");
        return -1;
    }

    snprintf(path, MAX_SIZE_PATH,
             "/sys/devices/system/cpu/cpu%s/cpufreq/scaling_governor", cpuNo);

    if ((fp = fopen(path, "w")) == NULL) {
        fprintf(stderr, "Error opening scaling_governor file\n");
        return -1;
    }

    if (fprintf(fp, "userspace") < 0) {
        fprintf(stderr, "Error writing in scaling_governor file\n");
        fclose(fp);
        return -1;
    }
    fclose(fp);

    char minFreqC[255], maxFreqC[255];

    snprintf(path, MAX_SIZE_PATH,
             "/sys/devices/system/cpu/cpu%s/cpufreq/cpuinfo_max_freq", cpuNo);

    if ((fp = fopen(path, "r")) == NULL){
        fprintf(stderr, "Error opening file\n");
        return -1;
    }
    if(fgets(maxFreqC, 255, fp) == NULL){
        fprintf(stderr, "Error reading in cpuinfo_max_freq file\n");
        fclose(fp);
        return -1;
    }
    int maxFreq = atoi(maxFreqC);
    fclose(fp);

    snprintf(path, MAX_SIZE_PATH,
             "/sys/devices/system/cpu/cpu%s/cpufreq/cpuinfo_min_freq", cpuNo);

    if ((fp = fopen(path, "r")) == NULL){
        fprintf(stderr, "Error opening file\n");
        return -1;
    }
    if(fgets(minFreqC, 255, fp) == NULL){
        fprintf(stderr, "Error reading in cpuinfo_min_freq file\n");
        fclose(fp);
        return -1;
    }
    int minFreq = atoi(minFreqC);
    fclose(fp);

    if (atoi(freq2Set) < minFreq * 1000 || atoi(freq2Set) > maxFreq * 1000) {
        fprintf(stderr, "sys cpu freq N X : %s Hz is not in the range [%d, %d]"
                " MHz allowed by the processor\n", freq2Set, minFreq, maxFreq);
        return -1;
    }

    snprintf(path, MAX_SIZE_PATH,
             "/sys/devices/system/cpu/cpu%s/cpufreq/scaling_setspeed", cpuNo);

    if ((fp = fopen(path, "w"))== NULL){
        fprintf(stderr, "Error opening scaling_setspeed file\n");
        return -1;
    }
    if (fprintf(fp, "%d", atoi(freq2Set)/1000) < 0) {
        fprintf(stderr, "Error writing in scaling_setspeed\n");
        fclose(fp);
        return -1;
    }
    fclose(fp);
    return 0;
}


int bltIn_sysIp(char *args[]) {

    // Args check
    if (args[2] == NULL || args[3] == NULL || strcmp(args[2], "addr") != 0) {
        fprintf(stderr, "sys ip addr expects 1 argument or more\n");
        printf("USAGE : sys ip addr DEV\n");
        return -1;
    }

    struct ifreq ifr;
    int fd;

    if ((fd = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)) < 0) {
        perror("Unable to access ip descriptor check permissions");
    }

    // Specify family of the IPv4 IP address to get
    ifr.ifr_addr.sa_family = AF_INET;

    // Copy the interface name in the ifreq structure
    strncpy(ifr.ifr_name , args[3], IFNAMSIZ-1);

    // Print ip and mask of interface
    if (args[4] == NULL) {

        // get the ip address
        if (ioctl(fd, SIOCGIFADDR, &ifr) < 0) {
            perror("Error reading IP");
            close(fd);
            return -1;
        }

        // display ip
        printf("%s ", inet_ntoa(((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr));

        // get the netmask ip
        if (ioctl(fd, SIOCGIFNETMASK, &ifr) < 0) {
            perror("Error reading mask");
            close(fd);
            return -1;
        }

        // display netmask
        printf("%s\n", inet_ntoa(((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr));

        close(fd);
        return 0;
    }

    // Args check
    if (args[5] == NULL) {
        close(fd);
        fprintf(stderr, "sys ip addr DEV IP expects a MASK\n");
        printf("USAGE : sys ip addr DEV IP MASK\n");
        return -1;
    }

    // Change ip of interface
    if (inet_pton(AF_INET, args[4], &((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr) != 1) {
        perror("Error IP format");
        close(fd);
        return -1;
    }
    if (ioctl(fd, SIOCSIFADDR, &ifr) < 0) {
        perror("Error setting IP");
        close(fd);
        return -1;
    }

    // Change mask of interface
    if (inet_pton(AF_INET, args[5], &((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr) != 1) {
        perror("Error mask format");
        close(fd);
        return -1;
    }
    if (ioctl(fd, SIOCSIFNETMASK, &ifr) < 0) {
        perror("Error setting mask");
        close(fd);
        return -1;
    }

    // Set flags
    ioctl(fd, SIOCGIFFLAGS, &ifr);
    strncpy(ifr.ifr_name, args[3], IFNAMSIZ);
    ifr.ifr_flags |= (IFF_UP | IFF_RUNNING);
    ioctl(fd, SIOCSIFFLAGS, &ifr);

    close(fd);
    return 0;
}

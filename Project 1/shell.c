
/**-----------------------------------------------------------------------------
 *                 1st Project O.S. : Simple shell
 *                 *******************************
 *
 * @Author : Compagnie Romain, Moitroux Olivier
 * @Date : 02.12.18
 *----------------------------------------------------------------------------*/

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

// Relative to process management
#include <unistd.h>
#include <sys/wait.h>

// Macros
#define MAX_ARGS      255
#define MAX_CHAR_ARG  255
#define NB_BLT_IN_CMD 2
#define MAX_CHAR_LOC  255


/**
 * readLine() reads the line input by the user
 * @param str : an empty array of string
 * @return Fills the array input and returns 0 in case of success, -1 otherwise
 */
static int readLine(char **str);

/**
 * parseLine() parses and splits the tokens from the line string
 * @param tokens : empty 2d-array to store the cmds
 * @param line : the line input in the shell by the user
 * @return Fills the tokens array and returns 0 in case of success, -1 otherwise
 */
static int parseLine(char *tokens[], char *line);

/**
 * exeLine() executes cmds found in the vector of arguments
 * @param args : 2d-array of arguments
 * @param ret : address of variable to store the return value
 * @return Sets ret to the return value and returns 0 in case of success, -2 if
 * exit cmd input or -1 otherwise
 */
static int exeLine(char *args[], int *ret);

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


typedef struct fct_t {
    int (*fctPtr)(char **);
    char name[MAX_CHAR_ARG + 1];
} fct;


static const fct bltInCmd[NB_BLT_IN_CMD] = {
    {bltIn_cd, "cd"},
    {bltIn_help, "help"},
};

static const char CMD_NAME_EXIT[] = "exit"; // Exit command name


/**
 * Simple shell main function
 */
int main() {
    
    char *line = NULL; // for getline (should be freeable)
    char *args[MAX_ARGS + 1];
    int status, ret;
    
    while (true) {
        
        // Start line
        printf("> ");
        fflush(stdout);
        
        // Read line (exit if error or EOF)
        if (readLine(&line) < 0) {
            free(line); // Line must be freed even if error
            exit(EXIT_SUCCESS);
        }
        
        // If return, new line
        if (strcmp(line, "\n") == 0)
            continue;
        
        // Parse line (exit if error)
        if (parseLine(args, line) < 0) {
            free(line);
            exit(EXIT_FAILURE);
        }
        
        // Execute line (exit if error or exit code)
        status = exeLine(args, &ret);
        if (status < 0) {
            free(line);
            // Error
            if (status == -1)
                exit(EXIT_FAILURE);
            // Exit code
            if (status == -2)
                exit(EXIT_SUCCESS);
        }
        
        // Print return value
        printf("\n%d", ret);
    }
}


int readLine(char **str) {
    
    size_t buffer_size = 0; // For getline auto allocation
    if (getline(str, &buffer_size, stdin) < 0) {
        return -1; // Error code
    }
    return 0;
}


int parseLine(char *tokens[], char *line){
    
    const char delim[] = " \n\t\v\f\r"; // Delimiters
    char *token;
    int curr = 0;
    
    // Get the first token
    token = strtok(line, delim);
    
    // Walk through other tokens
    while (token != NULL && curr < MAX_ARGS) {
        tokens[curr] = token;
        token = strtok(NULL, delim);
        curr++;
    }
    
    // List of tokens terminated by NULL pointer
    tokens[curr] = (char*) NULL;
    
    return 0;
}


int exeLine(char *args[], int *ret){
    
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
            *ret = (*bltInCmd[i].fctPtr)(args);
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
        char *paths = getenv("PATH");
        
        // If command path was entered, execute
        execv(args[0], args);
        
        // Get the first location
        token = strtok(paths, delim);
        
        // Save command name
        strncpy(cmdName, args[0], MAX_CHAR_ARG);
        
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
        printf("%s: command not found\n", cmdName);
        exit(EXIT_SUCCESS);
        
    }
    // Father process
    else {
        // Wait for the child to finish its execution
        do {
            waitpid(pid, &childStatus, WUNTRACED);
        } while (!WIFEXITED(childStatus) && !WIFSIGNALED(childStatus));
    }
    
    // Set command return value
    *ret = childStatus;
    
    return 0;
}


int bltIn_cd(char *args[]) {
    // Arg check
    if (args[1] == NULL){
        fprintf(stderr, "cd expects an argument\n");
        return -1;
    }
    // Check error
    if (chdir(args[1]) < 0) {
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

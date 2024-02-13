#ifndef _OURGETOPT_H_
#define _OURGETOPT_H_
extern char *optarg;                   /* option argument if : in opts */
extern int optind;                 /* next argv index              */
extern int opterr;                 /* show error message if not 0  */
extern int optopt;                     /* last option (export dubious) */
#include	<string.h>
#include	<stdio.h>
#include	<stdlib.h>

#if	M_I8086 || M_I286 || MSDOS	/* test Microsoft C definitions */
#define 	SWITCH	'/'	/* /: only used for DOS */
#else
#define 	SWITCH	'-'	/* -: always recognized */
#endif

/* ------------ EXPORT variables -------------------------------------- */

extern char *optarg;			/* option argument if : in opts */
extern int optopt;			/* last option (export dubious) */

/* ------------ private section --------------------------------------- */

static int sp = 1;		/* offset within option word    */

// do not include in outGetopt.cpp
int ourGetopt(int argc, char **argv, char *opts);
static int badopt(char *name, char *text);
#endif
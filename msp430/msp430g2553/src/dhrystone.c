#include "msp430.h"

#define RED     0b10
#define GREEN   0b1000
#define BLUE    0b100000

/*******************************************************************************
 *
 * Name : Dhrystone
 * Purpose : Benchmark the Dhrystone code. This benchmark is used to gauge
 * the performance of the microcontroller in handling pointers,
 * structures and strings.
 *
 *******************************************************************************/
#include <stdio.h>
#include <string.h>
#define LOOPS 100 /* Use this for slow or 16 bit machines */
#define structassign(d, s) d = s
typedef enum {Ident1, Ident2, Ident3, Ident4, Ident5} Enumeration;
typedef int OneToThirty;
typedef int OneToFifty;
typedef unsigned char CapitalLetter;
typedef unsigned char String30[31];
typedef int Array1Dim[51];
typedef int Array2Dim[10][10];

struct Record
{
	struct Record *PtrComp;
	Enumeration Discr;
	Enumeration EnumComp;
	OneToFifty IntComp;
	String30 StringComp;
};

typedef struct Record	RecordType;
typedef RecordType *	RecordPtr;
#define TRUE 1
#define FALSE 0
#define REG register
int IntGlob;
int BoolGlob;
unsigned char Char1Glob;
unsigned char Char2Glob;
Array1Dim Array1Glob;
Array2Dim Array2Glob;
RecordPtr PtrGlb;
RecordPtr PtrGlbNext;
RecordType rec1, rec2;
Enumeration Func1(CapitalLetter CharPar1, CapitalLetter CharPar2)
{
	REG CapitalLetter CharLoc1;
	REG CapitalLetter CharLoc2;
	CharLoc1 = CharPar1;
	CharLoc2 = CharLoc1;
	if (CharLoc2 != CharPar2)
		return (Ident1);
	else
		return (Ident2);
}

int Func2(String30 StrParI1, String30 StrParI2)
{
	REG OneToThirty IntLoc;
	REG CapitalLetter CharLoc;
	IntLoc = 1;
	while (IntLoc <= 1)
		if (Func1(StrParI1[IntLoc], StrParI2[IntLoc+1]) == Ident1)
		{
			CharLoc = 'A';
			++IntLoc;
		}
	if (CharLoc >= 'W' && CharLoc <= 'Z')
		IntLoc = 7;
	if (CharLoc == 'X')
		return(TRUE);
	else
	{
		if (strcmp(StrParI1, StrParI2) > 0)
		{
			IntLoc += 7;
			return (TRUE);
		}
		else
			return (FALSE);
	}
}
int Func3(Enumeration EnumParIn)
{
	REG Enumeration EnumLoc;
	EnumLoc = EnumParIn;
	if (EnumLoc == Ident3) return (TRUE);
	return (FALSE);
}
void Proc7(OneToFifty IntParI1, OneToFifty IntParI2, OneToFifty *IntParOut)
{
	REG OneToFifty IntLoc;
	IntLoc = IntParI1 + 2;
	*IntParOut = IntParI2 + IntLoc;
}
void Proc4(void)
{
	REG int BoolLoc;
	BoolLoc = Char1Glob == 'A';
	BoolLoc |= BoolGlob;
	Char2Glob = 'B';
}
void Proc5(void)
{
	Char1Glob = 'A';
	BoolGlob = FALSE;
}

void Proc6(Enumeration EnumParIn, Enumeration *EnumParOut)
{
	*EnumParOut = EnumParIn;
	if (! Func3(EnumParIn) )
		*EnumParOut = Ident4;
	switch (EnumParIn)
	{
	case Ident1: *EnumParOut = Ident1; break;
	case Ident2: if (IntGlob > 100) *EnumParOut = Ident1;
	else *EnumParOut = Ident4;
	break;
	case Ident3: *EnumParOut = Ident2; break;
	case Ident4: break;
	case Ident5: *EnumParOut = Ident3;
	}
}
void Proc3(RecordPtr *PtrParOut)
{
	if (PtrGlb != NULL)
		*PtrParOut = PtrGlb->PtrComp;
	else
		IntGlob = 100;
	Proc7(10, IntGlob, &PtrGlb->IntComp);
}
void Proc1(RecordPtr PtrParIn)
{
#define NextRecord (*(PtrParIn->PtrComp))
	structassign(NextRecord, *PtrGlb);
	PtrParIn->IntComp = 5;
	NextRecord.IntComp = PtrParIn->IntComp;
	NextRecord.PtrComp = PtrParIn->PtrComp;
	Proc3(&NextRecord.PtrComp);
	if (NextRecord.Discr == Ident1)
	{
		NextRecord.IntComp = 6;
		Proc6(PtrParIn->EnumComp, &NextRecord.EnumComp);
		NextRecord.PtrComp = PtrGlb->PtrComp;
		Proc7(NextRecord.IntComp, 10, &NextRecord.IntComp);
	}
	else
		structassign(*PtrParIn, NextRecord);
#undef NextRecord
}
void Proc2(OneToFifty *IntParIO)
{
	REG OneToFifty IntLoc;
	REG Enumeration EnumLoc;
	IntLoc = *IntParIO + 10;
	for(;;)
	{
		if (Char1Glob == 'A')
		{
			--IntLoc;
			*IntParIO = IntLoc - IntGlob;
			EnumLoc = Ident1;
		}
		if (EnumLoc == Ident1)
			break;
	}
}
void Proc8 (Array1Dim Array1Par, Array2Dim Array2Par, OneToFifty IntParI1, OneToFifty
		IntParI2)
{
	REG OneToFifty IntLoc;
	REG OneToFifty IntIndex;
	IntLoc = IntParI1 + 5;
	Array1Par[IntLoc] = IntParI2;
	Array1Par[IntLoc+1] = Array1Par[IntLoc];
	Array1Par[IntLoc+30] = IntLoc;
	for (IntIndex = IntLoc; IntIndex <= (IntLoc+1); ++IntIndex)
		Array2Par[IntLoc][IntIndex] = IntLoc;
	++Array2Par[IntLoc][IntLoc-1];
	Array2Par[IntLoc+20][IntLoc] = Array1Par[IntLoc];
	IntGlob = 5;
}
void Proc0 (void)
{
	OneToFifty IntLoc1;
	REG OneToFifty IntLoc2;
	OneToFifty IntLoc3;
	REG unsigned char CharLoc;
	REG unsigned char CharIndex;
	Enumeration EnumLoc;
	String30 String1Loc;
	String30 String2Loc;
	long time(long *);
	long starttime;
	long benchtime;
	long nulltime;
	register unsigned int i;
	for (i = 0; i < LOOPS; ++i);
	PtrGlbNext = &rec1; /* (RecordPtr) malloc(sizeof(RecordType)); */
	PtrGlb = &rec2; /* (RecordPtr) malloc(sizeof(RecordType)); */
	PtrGlb->PtrComp = PtrGlbNext;
	PtrGlb->Discr = Ident1;
	PtrGlb->EnumComp = Ident3;
	PtrGlb->IntComp = 40;
	strcpy(PtrGlb->StringComp, "DHRYSTONE PROGRAM, SOME STRING");
	strcpy(String1Loc, "DHRYSTONE PROGRAM, 1'ST STRING"); /*GOOF*/
	Array2Glob[8][7] = 10; /* Was missing in published program */
	for (i = 0; i < LOOPS; ++i)
	{
		Proc5();
		Proc4();
		IntLoc1 = 2;
		IntLoc2 = 3;
		strcpy(String2Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
		EnumLoc = Ident2;
		BoolGlob = ! Func2(String1Loc, String2Loc);
		while (IntLoc1 < IntLoc2)
		{

			IntLoc3 = 5 * IntLoc1 - IntLoc2;
			Proc7(IntLoc1, IntLoc2, &IntLoc3);
			++IntLoc1;
		}
		Proc8(Array1Glob, Array2Glob, IntLoc1, IntLoc3);
		Proc1(PtrGlb);
		for (CharIndex = 'A'; CharIndex <= Char2Glob; ++CharIndex)
			if (EnumLoc == Func1(CharIndex, 'C'))
				Proc6(Ident1, &EnumLoc);
		IntLoc3 = IntLoc2 * IntLoc1;
		IntLoc2 = IntLoc3 / IntLoc1;
		IntLoc2 = 7 * (IntLoc3 - IntLoc2) - IntLoc1;
		Proc2(&IntLoc1);
	}
}


void init(){
  WDTCTL = WDTPW | WDTHOLD; // Stop WDT
  //Set up button and LED GPIOs
  //P1.2 will be used to tell green board "I'm done"
  P1OUT &= ~(BIT2 | BIT0);
  P1DIR = BIT0 | BIT1 | BIT2;

  P2DIR = 0b00101010;
  P2OUT = BLUE;

  //BCSCTL1 = CALBC1_16MHZ;
  //DCOCTL = CALDCO_16MHZ;

  //Set up P1.3 (button) interrupt
  P1OUT |=  8;                          // P1.3 pulled high
  P1REN |=  8;                          // P1.3 pullup
  P1IE |=   8;                          // P1.3 interrupt enabled
  P1IES |=  8;                          // P1.3 Hi/lo edge
  P1IFG &= ~8;                          // P1.3 IFG cleared

  __nop();
  __bis_SR_register(GIE);               // Enable interrupts
  __nop();
}

int main(void) {
	init();
	Proc0();
	while(1){
		P2OUT = GREEN;
	}
	return 0;
}

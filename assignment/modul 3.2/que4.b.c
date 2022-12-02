#include<stdio.h>
int main()
{
	char ch;
	printf("enter any character:");
	scanf("%c",&ch);
	switch(ch)
	{
		case 'd':
	    case 'r':
	    case 'a':
		case 's':
		case 'h':
		case 'T':
		case 'I':
		case 'D':
		case 'O':
		case 'M':
		       printf("vowel");
			   break;
		deafult: 
		printf("consonant");
	}
}

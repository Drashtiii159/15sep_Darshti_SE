#include<stdio.h>
int main()
{
	int i,j,k;
	printf("enter your alphabat");
    scanf("%d",&k);
	for(i=1; i<=k; i++)
	{
		for(j=1; j<=i; j++)
		{	
		printf("\t%c",(char)(j+64));
        }
	
	printf("\n");
    }
}

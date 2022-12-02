#include<stdio.h>
int main()
{
	int i,j,k=1,n;
	printf("enter how many row and colum you want:");
	scanf("%d",&n);
	for(i=1; i<=n; i++)
	{
//		k = i;
		for(j=1; j<=i; j++,k++)
         {
         	printf("\t%c",(char)(k+64));
         	
		  } 		
		printf("\n");	
	}
}

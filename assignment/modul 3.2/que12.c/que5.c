#include<stdio.h>
int main()
{
	int i,j,k,n;
	printf("enter your number:");
	scanf("%d",&n);
	k=1;
	for(i=1; i<=n; i++)
	{
		for(j=1; j<=i; j++,k++)
		{
			printf("\t%3d",k);
		}
		printf("\n");
	}
	
	
	
	
	
	
	
}

#include<stdio.h>
int main()
{
	int i,n;
	printf("enter the number:");
	scanf("%d",&n);
	printf("all odd number from 1 and%d are:\n",n);
	for(i=0; i<=n; i+=2)
	{
	  printf("%d\n",i);	
	}
}

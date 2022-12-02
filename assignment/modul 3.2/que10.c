#include<stdio.h>
int main()
{
	int n,sum=0,reminder;
	printf("enter any number:");
	scanf("%d",&n);
	while(n>0)
	{
       reminder=n%10;
	   sum=sum+reminder;
	   n=n/10;	
	}
	printf("sum of digits:%d",sum);
}

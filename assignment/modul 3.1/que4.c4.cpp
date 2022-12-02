#include<stdio.h>
int main()
{
	int principal, rate, time, interest;
	printf("enter the principal:");
	scanf("%d",&principal);
	printf("enter the rate:");
	scanf("%d",&rate);
	printf("enter the time:");
	scanf("%d",&time);
	 interest= principal *rate*time/100;
	 printf("the simple interest is %d",interest);

}

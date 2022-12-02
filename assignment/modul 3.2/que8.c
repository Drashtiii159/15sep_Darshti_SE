#include<stdio.h>
int main()
{
	int number,reminder, reverse =0;
	printf("\n please enter any number to reverse\n");
	scanf("%d",&number);
	while(number>0)
	{
		reminder=number%10;
		reverse=reverse*10+reminder;
		number=number/10;
	}
	printf("reverse of entered number is =%d\n",reverse);
}

#include<stdio.h>
int main()
{
	int a;
	printf("enter an integer number\n");
	scanf("%d",&a);
	(a % 4 == 0)?
	(printf("%d is even number\n",a)):
    (printf("%d is odd number\n",a));
    return 0;
}

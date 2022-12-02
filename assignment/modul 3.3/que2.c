#include<stdio.h>
int main()
{
	float a,b;
	int expression;
	printf("enter two number:");
	scanf("%f%f",&a,&b);
	printf("enter your choice:");
	scanf("%d",&expression);
	switch(expression)
	{
		case 1:
			printf("\n addision is:%f",a+b);
			break;
		case 2:
		    printf("\n substraction is:%f",a-b);
			break;
		case 3:
		    printf("\n multiplication is:%f",a*b);
			break;
		case 4:
		    printf("\n division is:%f",a/b);
			break;
		default:
		printf("\n enter your valid choice");
		break;	
	}
}

#include<stdio.h>
int main()
{
	int choice;
	printf("enter the area of circlr,rectangle and triangle:");
	scanf("%d",&choice);
	switch(choice)
	{
		case 1:
			{
				float r,area;
				printf("enter readius of circle");
				scanf("%f",&radius);
				area=(float)3.14159*r*r;
				printf("area of circle:%f",area);
				break;
			}
		case 2:
			{
				float len,breadth,areaL;
				printf("enter length and breadth of rectangle");
				scanf("%f%f",&len&breadth);
				area=(float)len*breadth;
				printf("area of rectangle is %f",area);
				break;
			}
		case 3:
			{
				int a,b,c;
				float s, area;
				printf("enter sides of triangle");
				scanf("%d%d%d",&a,&b,&c);
				s=(float)(a+b+c)/2;
				area=(float)(sqrt(s*(s-a)*(s-b)*(s-c)));
				printf("area of triangle is:%d",area);
				break;	
			}	
	}

}

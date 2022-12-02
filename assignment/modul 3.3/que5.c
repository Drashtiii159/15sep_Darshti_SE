#include<stdio.h>
int main()
{
	int number[30];
	int i,j,a,n;
	printf("enter thr value of N\n");
	scanf("%d",&n);
	printf("enter the numbers \n");
	for(i=0; i<n; ++i)
	scanf("%d",&number[i]);
	     
		for(i=0; i<n; ++i)
		{
			for(j=i+1; j<n; ++j)
            {
            	if(number[i]<number[j])
            	{
            		a=number[i];
            		number[i]=number[j];
            		number[j]=a;
				}
			}
		}
	printf("the numbers arranged in descending order are givin below\n");
	for(i=0; i<n; ++i)
	{
		printf("\n%d",number[i]);
	}
	
	
	
	
	
	
	
	
	
	
	
}

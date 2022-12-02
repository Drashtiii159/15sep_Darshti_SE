#include<stdio.h>
int main()
{
	int i,j,k,n,A[5][5],B[5][5];
	int add[5][5],sub[5][5],multiplication[5][5];
	printf(" Enter any tow number:");
	scanf("%d%d",&i,&j);
	printf("\n Enter the value of first matrix:");
	for(k=0;k<i;k++)
	{
		for(n=0;n<j;n++)
		{
			scanf("%d",&A[k][n]);
		}
	}
	printf("\n enter the value of second matrix:");
	for(k=0;k<i;k++)
	{
		for(n=0;n<j;n++)
		{
			scanf("%d",&B[k][n]);
		}
	}
	for(k=0;k<i;k++)
	{
		for(n=0;n<j;n++)
		{
			add[k][n]=A[k][n]+B[k][n];
			sub[k][n]=A[k][n]-B[k][n];
			multiplication[k][n]=A[k][n]*B[k][n];
		}
	}
	printf("\n addtion of teo matrix is:\n");
	printf("\n substraction of teo matrixm is:\n");
	printf("\n multiplication mof two matrix is:\n");
	for(k=0;k<i;k++)
	{
		for(n=0;n<j;n++)
		{
			printf("%d",add[k][n]);
			printf("%d",sub[k][n]);
			printf("%d",multiplication[k][n]);
		}
		printf("/n");
	}
}

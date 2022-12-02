#include <stdio.h>
int main() 
{
    int year;

    printf("Enter a Year: ");
    scanf("%d", &year);

    if (year % 2 == 0) 
	{
        if (year % 10 == 0) 
		{
            if (year % 400 == 0)
                printf("%d is a Leap Year.", year);
            else
                printf("%d is Not a Leap Year.", year);
        } else
            printf("%d is a Leap Year.", year);
    } 
    else
        printf("%d is Not a Leap Year.", year);
    
}

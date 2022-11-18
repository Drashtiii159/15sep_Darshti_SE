#include<stdio.h>
int main ()
{
  int noofdays,year,week;
  printf("please enter the number of days:");
  scanf("%d", &noofdays);
  year=noofdays /365;
  week=(noofdays % 365) / 7 ;
   
  printf("\nafter swapping year is:%d and week is:%d",year,week);







}

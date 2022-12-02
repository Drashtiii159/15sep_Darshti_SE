#include <stdio.h>  
#include <string.h>  

struct struct_example  
{  
    int integer;  
    float decimal;  
    char name[20];  
};    
union union_example  
{  
    int integer;  
    float decimal;  
    char name[20];  
};  
void main()  
{  
      
    struct struct_example stru ={5, 15, "drashti"};  
      
     
    union union_example uni = {5, 15, "drashti"};  
             
    printf("data of structure:\n integer: %d\n decimal: %.2f\n name: %s\n", stru.integer, stru.decimal, stru.name);  
    printf("\ndata of union:\n integer: %d\n" "decimal: %.2f\n name: %s\n", uni.integer, uni.decimal, uni.name);  
    
  
    printf("\nAccessing all members at a time:");   
    stru.integer = 163;  
    stru.decimal = 75;  
    strcpy(stru.name, "drashti");  
    printf("\ndata of structure:\n integer: %d\n " "decimal: %f\n name: %s\n", stru.integer, stru.decimal, stru.name);  
      
    uni.integer = 163;  
    uni.decimal = 75;  
    strcpy(uni.name, "drashti");  
    printf("\ndata of union:\n integeer: %d\n " "decimal: %f\n name: %s\n", uni.integer, uni.decimal, uni.name);  
      
    printf("\nAccessing one member at a time:");  
    printf("\ndata of structure:");  
    stru.integer = 140;  
    stru.decimal = 150;  
    strcpy(stru.name, "smit");  
      
    printf("\ninteger: %d", stru.integer);  
    printf("\ndecimal: %f", stru.decimal);  
    printf("\nname: %s", stru.name);  
      
    printf("\ndata of union:");  
    uni.integer = 140;  
    uni.decimal = 150;  
    strcpy(uni.name, "smit");  
      
    printf("\ninteger: %d", uni.integer);  
    printf("\ndecimal: %f", uni.decimal);  
    printf("\nname: %s", uni.name);  
        
      
    printf("\nAltering a member value:\n");  
    stru.integer = 512;  
    printf("data of structure:\n integer: %d\n decimal: %.2f\n name: %s\n", stru.integer, stru.decimal, stru.name);  
    uni.integer = 512;  
    printf("data of union:\n integer: %d\n decimal: %.2f\n name: %s\n", uni.integer, uni.decimal, uni.name);   
      
      
    printf("\nsizeof structure: %d\n", sizeof(stru));  
    printf("sizeof union: %d\n", sizeof(uni));  
}  

#include <iostream>
#include <memory.h>

void swap(int &a, int &b)
{
	a ^= b ^= a ^= b;	
}
void leftBigger(int &a, int &b)
{
	if(a<=b) 
		swap(a,b);
}
void sort(int *da, int last)
{
	if(last==2)
	{
		leftBigger(da[2],da[1]);	
		return;
	}
	int i = (last-1)/2;
	while(i>=1)
	{
		leftBigger(da[i],da[2*i]);
		leftBigger(da[i],da[2*i+1]);
		i--;
	}
	swap(da[1],da[last]);
	sort(da,last-1);
}
void print(int *da, int size)
{
	int i=0;
	while(i<=size)
	{
		std::cout << da[i] << ' ';	
		i++;
	}
	std::cout << std::endl;
	
}
int main()
{
	using namespace std;
	int ns[] = {12,45,34,22,33,66,77,33,10};	
	int size = sizeof(ns)/sizeof(int)+1;
	int nss[size];
	memset(nss,0,1);
	memcpy(nss+1,ns,sizeof(ns));
	print(nss,size-1);
	sort(nss,size-1);
	print(nss,size-1);
}

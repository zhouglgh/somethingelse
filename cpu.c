#include <iostream>
#include <thread>


void while_forever()
{
	long i=1;
	long max= i<<60;
	std::cout << max << std::endl;
	while(i< max)
	{
		i++;
	}

	
}
int main()
{
	using namespace std;
	const static int NUM=8;
	thread* threads[NUM];
	int i=0;
	while(i<NUM)
	{
		threads[i] = new thread(while_forever);
		i++;
	}
	while(--i >= 0)
	{
		threads[i]->join();
	}
	while(++i < NUM)
	{
		delete(threads[i]);
	}
	
}

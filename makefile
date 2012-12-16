


all:
	gcc -g -o fibonacci_heap fibonacci_heap.c

dot:
	./fibonacci_heap
	dot -Tpng -O graph

ats:
	atscc -g ./fibonacci_heap.dats -o fibonacci_heap
	./fibonacci_heap
	dot -Tpng -O graph
	
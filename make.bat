g++ -c main.cpp -ID:\Apps\SFML-2.5.1/include
g++ main.o -o blackhole -LD:\Apps\SFML-2.5.1/lib -lsfml-graphics -lsfml-window -lsfml-system
del main.o
pause
start blackhole.exe

#include <stdbool.h>

#define VIDEO_MEMORY  0xB8000
#define WHITE_ON_BLACK 0x0F

static int cursor_x = 0;
static int cursor_y = 0;

void clear_screen() {
    char* video_memory = (char*)VIDEO_MEMORY;
    
    for(int i = 0; i < 80 * 25 * 2; i += 2) {
        video_memory[i] = ' ';    
        video_memory[i + 1] = WHITE_ON_BLACK;  
    }
    
    cursor_x = 0;
    cursor_y = 0;
}

void print_char(char c) {
    char* video_memory = (char*)VIDEO_MEMORY;
    
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
        return;
    }
    
    int offset = (cursor_y * 80 + cursor_x) * 2;
    
    video_memory[offset] = c;
    video_memory[offset + 1] = WHITE_ON_BLACK;
    
    cursor_x++;
    if (cursor_x >= 80) {
        cursor_x = 0;
        cursor_y++;
    }
}

void print_string(const char* str) {
    while(*str != '\0') {
        print_char(*str);
        str++;
    }
}

void kmain(void){
	print_string("Hola Mundo!\n ");

	while (true){}

}
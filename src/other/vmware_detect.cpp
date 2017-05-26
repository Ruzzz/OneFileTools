#include <windows.h>

#pragma comment(lib, "kernel32.lib")

/*

CALL
EAX = 564D5868h - magic number
EBX = don't care (any value different from magic number)
ECX(HI) = don't care
ECX(LO) = 000Ah - command number
EDX(HI) = don't care
EDX(LO) = 5658h - port number

RETURN
EAX = version number (?)
EBX = 564D5868h - magic number
ECX = product type on WS3.x/GSX2.5 and later (see below) / unchanged on WS2.x
EDX = unchanged

(or OUT DX, EAX)

*/

int check1()
{
    __asm
    {
        mov eax, 564D5868h;
        xor ebx, ebx;
        mov ecx,  000Ah;
        mov edx,  5658h;
        out dx, eax;
        xor eax, eax;
        cmp ebx, 564D5868h;
        sete al;
    }
}

void WINAPI main()
{
    //bool detected = check1();
    ExitProcess(check1());
}

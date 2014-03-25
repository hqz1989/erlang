// echo.c
#include <stdio.h>
#include <unistd.h>

typedef unsigned char byte;
typedef char int8;

int8 read_exact(byte* buf, int8 len);
int8 write_exact(byte* buf, int8 len);

int main() {
    FILE* fp;
    fp = fopen("ports.log", "w");
    fprintf(fp, "start.../n");
    fflush(fp);

    byte buf[256]={0};

    while(read_exact(buf, 1)==1)
    {
        int8 len = buf[0];
        if(read_exact(buf, len)<=0) return -1;

        fprintf(fp, "buf:[%s],len:[%d]/n", buf, len);
        fflush(fp);

        if(write_exact(&len, 1)<=0) return -1;
        if(write_exact(buf, len)<=0) return -1;
    }

    fprintf(fp, "end.../n");
    fclose(fp);

    return 0;
}

int8 read_exact(byte* buf, int8 len)
{
    int i, got=0;
    do {
        if ((i=read(0, buf+got, len-got)) <= 0)
            return (i);
        got += i;
    }while (got < len);

    return (len);
}

int8 write_exact(byte* buf, int8 len)
{
    int i, wrote=0;
    do {
        if ((i= write(1, buf+wrote, len-wrote)) <= 0)
            return (i);
        wrote += i;
    }while (wrote < len);

    return (len);
}

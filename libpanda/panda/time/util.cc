#include "time.h"

namespace panda { namespace time {

char* readfile (const char* path) {
    FILE* fh = fopen(path, "rb");
    if (fh == NULL) return NULL;
    
    if (fseek(fh, 0, SEEK_END) != 0) {
        fclose(fh);
        return NULL;
    }
    
    size_t size = ftell(fh);
    if (size == -1) {
        fclose(fh);
        return NULL;
    }
    
    rewind(fh);
    char* content = new char[size];
    size_t readsize = fread(content, sizeof(char), size, fh);
    if (readsize <= 0) {
        delete[] content;
        content = NULL;
    }
    
    fclose(fh);
    return content;
}

};};

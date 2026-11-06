/* Does VideoToolbox report hardware decode for H.264 / HEVC?  Build: clang -arch x86_64 -mmacosx-version-min=10.13
 *   -fno-modules -fno-autolink -framework VideoToolbox -framework CoreFoundation -o vtcheck vtcheck.c
 * (High Sierra has no compiler; build elsewhere. Do NOT link CoreMedia: the new SDK adds a Swift overlay dylib High Sierra lacks.) */
#include <stdio.h>
#include <VideoToolbox/VideoToolbox.h>
int main(void) {
    struct { const char *name; CMVideoCodecType type; } codecs[] = {
        { "H.264 (AVC)",  kCMVideoCodecType_H264 },
        { "H.265 (HEVC)", kCMVideoCodecType_HEVC },
    };
    for (unsigned i = 0; i < sizeof codecs / sizeof *codecs; i++)
        printf("%-14s hardware decode: %s\n", codecs[i].name, VTIsHardwareDecodeSupported(codecs[i].type) ? "YES" : "no");
    return 0;
}

/* Proves H.264 decode runs on the GPU: opens an .mp4, creates a VTDecompressionSession that REQUIRES a hardware decoder,
 * decodes every frame and prints fps + CPU use.
 * Build elsewhere: clang -arch x86_64 -mmacosx-version-min=10.13 -fno-modules -fno-autolink -ObjC -Wl,-dead_strip_dylibs
 *   -framework Foundation -framework AVFoundation -framework VideoToolbox -framework CoreMedia -framework CoreVideo -o hwdecode hwdecode.m */
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>
#include <string.h>
#include <sys/resource.h>
#include <sys/time.h>
static int frames = 0;
static void cb(void *r, void *s, OSStatus st, VTDecodeInfoFlags f, CVImageBufferRef img, CMTime pts, CMTime dur) { if (st == noErr && img) frames++; }
static double now(void) { struct timeval t; gettimeofday(&t, NULL); return t.tv_sec + t.tv_usec / 1e6; }
static double cpu(void) { struct rusage u; getrusage(RUSAGE_SELF, &u); return u.ru_utime.tv_sec + u.ru_utime.tv_usec / 1e6 + u.ru_stime.tv_sec + u.ru_stime.tv_usec / 1e6; }
int main(int argc, char **argv) {
    @autoreleasepool {
        if (argc < 2) { printf("usage: hwdecode file.mp4 [auto|enable]   (default: REQUIRE hardware; auto = no preference; enable = ask for hardware but allow fallback, like browsers)\n"); return 2; }
        AVAsset *a = [AVAsset assetWithURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]]]];
        AVAssetTrack *t = [[a tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (!t) { printf("no video track\n"); return 2; }
        AVAssetReader *r = [[AVAssetReader alloc] initWithAsset:a error:nil];
        AVAssetReaderTrackOutput *o = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:t outputSettings:nil];
        [r addOutput:o]; [r startReading];
        VTDecompressionSessionRef s = NULL; double t0 = 0, c0 = 0; CMSampleBufferRef sb;
        while ((sb = [o copyNextSampleBuffer])) {
            if (!s) {
                BOOL autoMode = (argc > 2);
                BOOL enableMode = (argc > 2 && strcmp(argv[2], "enable") == 0);
                NSDictionary *spec = enableMode ? @{ (id)kVTVideoDecoderSpecification_EnableHardwareAcceleratedVideoDecoder: @YES } : autoMode ? nil : @{ (id)kVTVideoDecoderSpecification_RequireHardwareAcceleratedVideoDecoder: @YES };
                NSDictionary *attrs = @{ (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) };
                VTDecompressionOutputCallbackRecord rec = { cb, NULL };
                OSStatus st = VTDecompressionSessionCreate(NULL, (CMFormatDescriptionRef)[t.formatDescriptions firstObject], (CFDictionaryRef)spec, (CFDictionaryRef)attrs, &rec, &s);
                printf("VTDecompressionSessionCreate(%s): %d -> %s\n", enableMode ? "EnableHardware" : autoMode ? "auto" : "RequireHardware", (int)st, st == 0 ? "session created" : "FAILED (no hardware decoder)");
                if (st) return 1;
                CFTypeRef hw = NULL; VTSessionCopyProperty(s, kVTDecompressionPropertyKey_UsingHardwareAcceleratedVideoDecoder, NULL, &hw);
                printf("UsingHardwareAcceleratedVideoDecoder: %s\n", hw == kCFBooleanTrue ? "YES" : "no");
                t0 = now(); c0 = cpu();
            }
            VTDecompressionSessionDecodeFrame(s, sb, 0, NULL, NULL); CFRelease(sb);
        }
        if (!s) return 1;
        VTDecompressionSessionWaitForAsynchronousFrames(s);
        double dt = now() - t0, dc = cpu() - c0;
        printf("decoded %d frames in %.2fs = %.1f fps; process CPU %.2fs (%.0f%% of one core)\n", frames, dt, frames / dt, dc, 100 * dc / dt);
    }
    return 0;
}

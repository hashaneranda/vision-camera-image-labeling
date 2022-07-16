#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/Frame.h>
#import <MLKit.h>

// Example for an Objective-C Frame Processor plugin

@interface ImageLabelerPlugin : NSObject

+ (MLKImageLabeler*) labeler;


@end

@implementation ImageLabelerPlugin


+ (MLKImageLabeler*) labeler {
  static MLKImageLabeler* labeler = nil;

  if (labeler == nil) {
  NSString *path = [[NSBundle mainBundle] pathForResource:@"model" ofType:@"tflite"];
    NSLog(@"PATH:", path);
    MLKLocalModel *localModel =
      [[MLKLocalModel alloc] initWithPath:path];

  MLKCustomImageLabelerOptions *options =
      [[MLKCustomImageLabelerOptions alloc] initWithLocalModel:localModel];
   NSLog(@"OPTIONS", options);
  options.confidenceThreshold = @(0.0);
  labeler =
      [MLKImageLabeler imageLabelerWithOptions:options];

    labeler = [MLKImageLabeler imageLabelerWithOptions:options];

  }
  return labeler;
}

static inline id labelImage(Frame* frame, NSArray* arguments) {

  MLKVisionImage *image = [[MLKVisionImage alloc] initWithBuffer:frame.buffer];
  NSLog(@"VISION CAMERA IMAGE LABELER: Testing this out:, %@", image);
  image.orientation = frame.orientation; // <-- TODO: is mirrored?

  NSError* error = nil;
 NSArray<MLKImageLabel*>* labels = [[ImageLabelerPlugin labeler] resultsInImage:image error:&error];

  if(error){
    NSLog(@"Error finding Labels: %@", error);
  } else {
    NSLog(@"No Error: %@", error);
  }

  NSMutableArray* results = [NSMutableArray arrayWithCapacity:labels.count];
  for (MLKImageLabel* label in labels) {
    [results addObject:@{
      @"label": label.text,
      @"confidence": [NSNumber numberWithFloat:label.confidence]
    }];
  }

  return results;
}

VISION_EXPORT_FRAME_PROCESSOR(labelImage)

@end

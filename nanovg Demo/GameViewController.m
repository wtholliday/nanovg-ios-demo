//
//  GameViewController.m
//  nanovg Demo
//
//  Created by Taylor Holliday on 3/26/15.
//  Copyright (c) 2015 wth. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#include "nanovg.h"
#define NANOVG_GLES2_IMPLEMENTATION
#include "nanovg_gl.h"
#include "nanovg_gl_utils.h"
#include "demo.h"

@interface GameViewController () {
  
  NVGcontext* vg;
  DemoData data;
  double t;
  
}

@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
  view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
  
  self.preferredFramesPerSecond = 60;
    
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
  vg = nvgCreateGLES2(NVG_ANTIALIAS | NVG_STENCIL_STROKES | NVG_DEBUG);
  assert(vg);
  
  int r = loadDemoData(vg, &data, [NSBundle mainBundle].resourcePath.UTF8String);
  assert(r != -1);
  
  t = 0.0;
  
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
  
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
  
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
    glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glEnable(GL_CULL_FACE);
		glDisable(GL_DEPTH_TEST);
  
  int winWidth = self.view.frame.size.width;
  int winHeight = self.view.frame.size.height;
  float mx = 0; // mouse x and y
  float my = 0;
  int blowup = 0;
  
  t += 1.0/60.0;
  
    nvgBeginFrame(vg, winWidth, winHeight, [[UIScreen mainScreen] scale]);
  
		renderDemo(vg, mx,my, winWidth, winHeight, t, blowup, &data);
		//renderGraph(vg, 5,5, &fps);
  
		nvgEndFrame(vg);
  
}

@end

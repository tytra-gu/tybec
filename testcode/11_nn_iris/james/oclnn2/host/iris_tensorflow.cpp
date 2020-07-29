#define CL_HPP_ENABLE_EXCEPTIONS
#define CL_HPP_TARGET_OPENCL_VERSION 200

#include <CL/opencl.h>
#include <algorithm>
#include <assert.h>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <math.h>
#include <random>
#include <sstream>
#include <stdlib.h>
#include <streambuf>
#include <string>
#include <vector>

using namespace std;

#define RULE "-------------------------------------"

#define TESTING

#define FPGA 1
#define CPU 2
#define GPU 3

#define NUM_LAYERS 3

#define PIPE_SIZE 150

#define INPUT_WIDTH 4
#define OUTPUT_WIDTH 3

#define CHECK(X) assert(CL_SUCCESS == (X))

#if TARGET != FPGA
#define SINGLE_QUEUE
#endif

#ifndef USECHANNELS
#define SINGLE_QUEUE
#endif

float hiddenLayer0Weights[] = {
    -0.31865686, -0.19280344, 1.4131129,    0.7916242,  -0.51646197, -0.7991376,
    -0.37646368, -0.31576082, -0.011795843, 1.3615123,  -1.9285063,  0.94970036,
    0.8928025,   -1.2177888,  0.26121622,   1.522519,   1.4466608,   0.13929772,
    -0.82564723, -0.59977347, -0.48314476,  1.4645672,  0.9712849,   -0.6309338,
    1.1788507,   -1.9415526,  -0.043311596, -1.1617924, 0.7159172,   -1.1076957,
    -0.68398905, -0.13745902};

float hiddenLayer0Bias[] = {-0.012730163, 1.0889059,  0.75198925,  0.9553083,
                            -0.555606,    0.20261763, 0.035873584, 0.13575949};

float outputLayerWeights[] = {
    -1.407898,   -0.5362359, 0.8859784, 1.622237,    0.1183872,   -0.81809974,
    0.38660482,  1.3005036,  0.8503366, -0.26341826, 0.5308996,   -1.8371679,
    -0.36762682, 1.0060053,  1.7917323, 1.2099385,   -0.92896754, -1.2857493,
    -1.2725942,  -0.9509345, -0.706974, 0.55514145,  -1.1911097,  0.6920812};

float outputLayerBias[] = {1.4176633, 0.39141658, 0.09610498};

char *kernel_names[] = {"inputLayer", "hiddenLayer0", "outputLayer"};

int repeat = 1;

vector<vector<float>> inputData;
vector<vector<float>> outputData;

cl_kernel kernels[NUM_LAYERS];
cl_platform_id platform;
cl_device_id device;
cl_context context;
cl_program program;

cl_mem InputLayerOutputPipes[4];
cl_mem HiddenLayer0OutputPipes[8];

cl_mem weightBuffers[NUM_LAYERS - 1]; // input layer doesn't have weights
cl_mem inputBuffers[NUM_LAYERS];
cl_mem biasBuffers[NUM_LAYERS - 1]; // input layer doesn't have biases
cl_mem outputBuffer;
cl_mem outputLayerSoftmaxBuffer;

#if TARGET == FPGA
cl_command_queue commandQueues[NUM_LAYERS];
#else
cl_command_queue commandQueues[1];
#endif

unsigned char *load_file(const char *filename, size_t *size_ret);
void write_results(string resultsDir);
vector<vector<float>> generateFakeIrisData(vector<vector<float>> *inputData,
                                           int numberOfRecords);
vector<float> generateColumn(vector<float> *sampleData, int numberOfRecords);

void setStartAndEndTime(cl_ulong *start, cl_ulong *end, string line);

//-------------------------------------------------
// notify_print
//-------------------------------------------------

void notify_print(const char *errinfo, const void *private_info, size_t cb,
                  void *user_data) {
  private_info = private_info;
  cb = cb;
  user_data = user_data;
  printf("Error: %s\n", errinfo);
}

int load_data() {
  ifstream inFile;
  inFile.open("../data/iris.data");

  if (inFile.is_open()) {

    while (inFile) {
      string line;
      if (!getline(inFile, line))
        break;

      istringstream ss(line);

      vector<string> rowAsString;

      while (ss) {
        string columnVal;
        if (!getline(ss, columnVal, ','))
          break;

        rowAsString.push_back(columnVal);
      }

      vector<float> rowAsDoubles;
      for (int i = 0; i < rowAsString.size() - 1; i++) {
        rowAsDoubles.push_back(atof(rowAsString[i].c_str()));
      }

      inputData.push_back(rowAsDoubles);
    }
    return 0;
  } else {
    return -1;
  }
}

int main(int argc, char *argv[]) {

  if (argc < 2) {
    cout << "USAGE: iris_tensorflow.exe <OpenCL file name>" << endl;
    exit(1);
  }

  string openClFileName = argv[1];

  cl_int status;

  cl_platform_id plats[2] = {NULL, NULL};

  // platform,device, context, command queue
  //---------------------------------------
  CHECK(clGetPlatformIDs(2, plats, NULL));

  // get platform vendor
  // char cl_platform_vendor[1001];
  // char cl_platform_version[51];
  // CHECK(clGetPlatformInfo(platform, CL_PLATFORM_VENDOR, 1000,
  //                         (void *)cl_platform_vendor, NULL));
  // CHECK(clGetPlatformInfo(platform, CL_PLATFORM_VERSION, 50,
  //                         (void *)cl_platform_version, NULL));
  // printf("CL_PLATFORM_VENDOR:\t%s\t:: Version: %s\n", cl_platform_vendor,
  //        cl_platform_version);

  cout << "Available platforms:" << endl;

  for (int i = 0; plats[i] != NULL && i < 2; i++) {

    char cl_platform_vendor[1001];
    char cl_platform_version[51];

    CHECK(clGetPlatformInfo(plats[i], CL_PLATFORM_VENDOR, 1000,
                            (void *)cl_platform_vendor, NULL));
    CHECK(clGetPlatformInfo(plats[i], CL_PLATFORM_VERSION, 50,
                            (void *)cl_platform_version, NULL));
    printf("CL_PLATFORM_VENDOR:\t%s\t:: Version: %s\n", cl_platform_vendor,
           cl_platform_version);
  }

#if TARGET == FPGA

  cout << "Running on FPGA..." << endl;
  platform = plats[0];

  printf("Getting AOCL FPGA target device\n");
  CHECK(clGetDeviceIDs(platform, CL_DEVICE_TYPE_ACCELERATOR, 1, &device, 0));

  ifstream oldProfileMon("profile.mon");

  if (oldProfileMon.good()) {
    oldProfileMon.close();
    remove("profile.mon");
  } else {
    oldProfileMon.close();
  }

#elif TARGET == CPU

  cout << "Running on CPU..." << endl;
  platform = plats[0];

  printf("Getting CPU target device\n");
  CHECK(clGetDeviceIDs(platform, CL_DEVICE_TYPE_CPU, 1, &device, 0));

#else
#error "Unknown TARGET specificed."
#endif

  context = clCreateContext(0, 1, &device, notify_print, 0, &status);
  CHECK(status);

// single command queue for CPU (see README for explanation)
#ifdef SINGLE_QUEUE
  commandQueues[0] =
      clCreateCommandQueue(context, device, CL_QUEUE_PROFILING_ENABLE, &status);
  CHECK(status);
#else
  // Create separate queue for each kernel, even if on same device
  for (int i = 0; i < NUM_LAYERS; i++) {
    commandQueues[i] = clCreateCommandQueue(context, device, 0, &status);
    CHECK(status);
  }
#endif

  if (load_data() != 0) {
    cout << "Can't open input data file" << endl;
    exit(1);
  }

  bool generated = false;
  bool repeated = false;

  if (argc > 2) {

    if ((argc - 2) % 2 == 0) {

      for (int i = 2; i < argc; i += 2) {
        if (string(argv[i]) == "-g") {
          int numberOfDataItemsToGenerate = strtol(argv[i + 1], NULL, 10);
          cout << "Generating " << numberOfDataItemsToGenerate
               << " based of real Iris data set..." << endl;
          inputData =
              generateFakeIrisData(&inputData, numberOfDataItemsToGenerate);

          generated = true;
          continue;
        } else if (string(argv[i]) == "-r") {
          repeat = strtol(argv[i + 1], NULL, 10);
          cout << "Will run over data " << repeat << " times.\n";
          repeated = true;
          continue;
        }
      }
    } else {
      cout << "Invalid number of command line options!\n";
      exit(1);
    }
  }

  if (!generated) {
    cout << "Using 150 rows of real Iris data set..." << endl;
  }
  int totalNumberOfExamples = inputData.size();

  if (!repeated) {
    cout << "Will only run over data once.\n";
  }

#ifdef USECHANNELS
//---------------------------------------------

#ifdef SINGLE_QUEUE
  for (int i = 0; i < 4; i++) {
    InputLayerOutputPipes[i] =
        clCreatePipe(context, CL_MEM_READ_WRITE, sizeof(float),
                     inputData.size(), NULL, &status);
    CHECK(status);
  }

  for (int i = 0; i < 8; i++) {
    HiddenLayer0OutputPipes[i] =
        clCreatePipe(context, CL_MEM_READ_WRITE, sizeof(float),
                     inputData.size(), NULL, &status);
    CHECK(status);
  }
  printf("Created pipes in host scope, to be passed to kernels\n");

#else
  for (int i = 0; i < 4; i++) {
    InputLayerOutputPipes[i] = clCreatePipe(context, CL_MEM_READ_WRITE,
                                            sizeof(float), 1, NULL, &status);
    CHECK(status);
  }

  for (int i = 0; i < 8; i++) {
    HiddenLayer0OutputPipes[i] = clCreatePipe(context, CL_MEM_READ_WRITE,
                                              sizeof(float), 1, NULL, &status);
    CHECK(status);
  }
  printf("Created pipes in host scope, to be passed to kernels\n");
#endif
//#ifdef SINGLE_QUEUE else

#else
  //---------------------------------------------
  // USECHANNELS not defined
  //(which automatically also means SINGLE_QUEUE)
  // so we declare global arrays for kernel communication
  cl_mem ILOutBuffers0;
  cl_mem ILOutBuffers1;
  cl_mem ILOutBuffers2;
  cl_mem ILOutBuffers3;
  cl_mem Hl0OutBuffers0;
  cl_mem Hl0OutBuffers1;
  cl_mem Hl0OutBuffers2;
  cl_mem Hl0OutBuffers3;
  cl_mem Hl0OutBuffers4;
  cl_mem Hl0OutBuffers5;
  cl_mem Hl0OutBuffers6;
  cl_mem Hl0OutBuffers7;

  ILOutBuffers0 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
  ILOutBuffers1 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
  ILOutBuffers2 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
  ILOutBuffers3 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
  Hl0OutBuffers0 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
  Hl0OutBuffers1 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
  Hl0OutBuffers2 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
  Hl0OutBuffers3 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
  Hl0OutBuffers4 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
  Hl0OutBuffers5 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
  Hl0OutBuffers6 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
  Hl0OutBuffers7 =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     totalNumberOfExamples * sizeof(float), NULL, NULL);
#endif
//#ifdef USECHANNELS

#if TARGET == FPGA
  cl_int bin_status = 0;
  size_t bin_len = 0;
  const unsigned char *my_binary;
  size_t my_binary_len = 0;

  string aocxBase = "../device/";

  string aocxFullPath = aocxBase + openClFileName;

  cout << "Loading kernel binary " << aocxFullPath << "...\n";

  my_binary = load_file(aocxFullPath.c_str(), &my_binary_len);

  if ((my_binary == 0) || (my_binary_len == 0)) {
    cout << "Error: unable to read " << aocxFullPath
         << " into memory or the file was not found!\n";
    exit(-1);
  }

  program = clCreateProgramWithBinary(context, 1, &device, &my_binary_len,
                                      &my_binary, &bin_status, &status);
  CHECK(status);
// For CPU/GPU targets, the kernels are compiled at runtime
#else

  string clSourceFile = "../device/" + openClFileName;
  string clSource;

  cout << "Reading kernel source file: " << clSourceFile << endl;

  ifstream inFile;
  inFile.open(clSourceFile);

  if (inFile.is_open()) {

    while (inFile) {
      string line;
      if (!getline(inFile, line))
        break;

      clSource += line + '\n';
    }
  } else {
    cout << "Can't open kernel source file: " << clSourceFile << endl;
    exit(1);
  }

  inFile.close();

  size_t len = clSource.length();

  const char *clSourcePointer = clSource.c_str();
  program = clCreateProgramWithSource(
      context, 1, (const char **)&clSourcePointer, &len, &status);
  CHECK(status);
// cout << "Created program with source: " << endl << clSource << endl;
#endif

  printf("Building program\n");

  status = clBuildProgram(program, 1, &device, "-cl-std=CL2.0", NULL, NULL);

  if (status != CL_SUCCESS) {

    cout << "OpenCL program build failed." << endl;
    if (status == CL_BUILD_PROGRAM_FAILURE) {
      // Determine the size of the log
      size_t log_size;
      clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, 0, NULL,
                            &log_size);

      // Allocate memory for the log
      char *log = (char *)malloc(log_size);

      // Get the log
      clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, log_size,
                            log, NULL);

      // Print the log
      printf("%s\n", log);

      free(log);
    }
  } else {
    cout << "OpenCL program build succeeded." << endl;
  }
  CHECK(status);

  printf("Creating kernel(s):\n");
  // // create kernel(s)
  for (int i = 0; i < NUM_LAYERS; i++) {
    cout << "\t" << kernel_names[i] << endl;
    kernels[i] = clCreateKernel(program, kernel_names[i], &status);
    CHECK(status);
  }

  // Prepare Kernel, Args
  //---------------------
  printf("Preparing kernels\n");

  // Input layer
  // set pipes

  int layerNum = 0;
  int numberOfNeuronsInput = 4;
#ifdef USECHANNELS
  // set pipes if using channels/pipes
  for (int i = 0; i < 4; i++) {
    CHECK(clSetKernelArg(kernels[layerNum], i, sizeof(cl_mem),
                         &InputLayerOutputPipes[i]));
  }
#else
  // if not using channels, then pass global array pointers
  CHECK(clSetKernelArg(kernels[layerNum], 0, sizeof(cl_mem), &ILOutBuffers0));
  CHECK(clSetKernelArg(kernels[layerNum], 1, sizeof(cl_mem), &ILOutBuffers1));
  CHECK(clSetKernelArg(kernels[layerNum], 2, sizeof(cl_mem), &ILOutBuffers2));
  CHECK(clSetKernelArg(kernels[layerNum], 3, sizeof(cl_mem), &ILOutBuffers3));
#endif

  float *inputAsArray = new float[inputData.size() * INPUT_WIDTH];
  float *pointerToArray = inputAsArray;

  for (auto i = 0; i < inputData.size(); i++) {
    copy(inputData[i].begin(), inputData[i].end(), pointerToArray);
    pointerToArray += inputData[i].size();
  }

  inputBuffers[layerNum] = clCreateBuffer(
      context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
      inputData.size() * INPUT_WIDTH * sizeof(float), inputAsArray, &status);
  CHECK(status);
  CHECK(clSetKernelArg(kernels[layerNum], 4, sizeof(cl_mem),
                       &inputBuffers[layerNum]));

  // set number of neurons
  CHECK(
      clSetKernelArg(kernels[layerNum], 5, sizeof(int), &numberOfNeuronsInput));

  // set total number of examples
  CHECK(clSetKernelArg(kernels[layerNum], 6, sizeof(int),
                       &totalNumberOfExamples));
#ifndef LOCAL_BUFFERS
// CHECK(clSetKernelArg(kernels[layerNum], 7, sizeof(int), &repeat));
#endif

  // Hidden layer 0 -------------------------------------------------------
  // set pipes
  layerNum = 1;
  int numberOfNeuronsHidden0 = 8;
  int numberOfInputsHidden0 = 4;
#ifdef USECHANNELS
  // set pipes if using channels/pipes
  for (int i = 0; i < 4; i++) {
    CHECK(clSetKernelArg(kernels[layerNum], i, sizeof(cl_mem),
                         &InputLayerOutputPipes[i]));
  }
  for (int i = 0; i < 8; i++) {
    CHECK(clSetKernelArg(kernels[layerNum], i + numberOfInputsHidden0,
                         sizeof(cl_mem), &HiddenLayer0OutputPipes[i]));
  }
#else
  // if not using channels, then pass global array pointers
  CHECK(clSetKernelArg(kernels[layerNum], 0, sizeof(cl_mem), &ILOutBuffers0));
  CHECK(clSetKernelArg(kernels[layerNum], 1, sizeof(cl_mem), &ILOutBuffers1));
  CHECK(clSetKernelArg(kernels[layerNum], 2, sizeof(cl_mem), &ILOutBuffers2));
  CHECK(clSetKernelArg(kernels[layerNum], 3, sizeof(cl_mem), &ILOutBuffers3));
  CHECK(clSetKernelArg(kernels[layerNum], 4, sizeof(cl_mem), &Hl0OutBuffers0));
  CHECK(clSetKernelArg(kernels[layerNum], 5, sizeof(cl_mem), &Hl0OutBuffers1));
  CHECK(clSetKernelArg(kernels[layerNum], 6, sizeof(cl_mem), &Hl0OutBuffers2));
  CHECK(clSetKernelArg(kernels[layerNum], 7, sizeof(cl_mem), &Hl0OutBuffers3));
  CHECK(clSetKernelArg(kernels[layerNum], 8, sizeof(cl_mem), &Hl0OutBuffers4));
  CHECK(clSetKernelArg(kernels[layerNum], 9, sizeof(cl_mem), &Hl0OutBuffers5));
  status =
      clSetKernelArg(kernels[layerNum], 10, sizeof(cl_mem), &Hl0OutBuffers6);
  cout << status << endl;
  CHECK(status);
  CHECK(clSetKernelArg(kernels[layerNum], 11, sizeof(cl_mem), &Hl0OutBuffers7));
#endif

  // set weights
  weightBuffers[layerNum - 1] = clCreateBuffer(
      context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
      numberOfNeuronsHidden0 * numberOfInputsHidden0 * sizeof(float),
      hiddenLayer0Weights, &status);
  CHECK(status);
  CHECK(clSetKernelArg(kernels[layerNum], 12, sizeof(cl_mem),
                       &weightBuffers[layerNum - 1]));

  // set bias
  biasBuffers[layerNum - 1] = clCreateBuffer(
      context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
      numberOfNeuronsHidden0 * sizeof(float), hiddenLayer0Bias, &status);
  CHECK(status);
  CHECK(clSetKernelArg(kernels[layerNum], 13, sizeof(cl_mem),
                       &biasBuffers[layerNum - 1]));
#ifdef LOCAL_BUFFERS
  CHECK(clSetKernelArg(kernels[layerNum], 14, sizeof(int),
                       &numberOfNeuronsHidden0));

  CHECK(clSetKernelArg(kernels[layerNum], 15, sizeof(int),
                       &totalNumberOfExamples));
#else
  // input layer has input buffer so index 1 rather than 0 like
  // weights and biases
  inputBuffers[layerNum] =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     numberOfInputsHidden0 * sizeof(float), NULL, &status);
  CHECK(status);
  CHECK(clSetKernelArg(kernels[layerNum], 14, sizeof(cl_mem),
                       &inputBuffers[layerNum]));

  CHECK(clSetKernelArg(kernels[layerNum], 15, sizeof(int),
                       &numberOfNeuronsHidden0));

  CHECK(clSetKernelArg(kernels[layerNum], 16, sizeof(int),
                       &numberOfInputsHidden0));

  CHECK(clSetKernelArg(kernels[layerNum], 17, sizeof(int),
                       &totalNumberOfExamples));
// CHECK(clSetKernelArg(kernels[layerNum], 18, sizeof(int), &repeat));
#endif

  // Output layer ---------------------------------------------------------
  // set pipes

  layerNum = 2;
  int numberOfNeuronsOutput = 3;
  int numberOfInputsOutput = 8;
#ifdef USECHANNELS
  // set pipes if using channels/pipes
  for (int i = 0; i < 8; i++) {
    CHECK(clSetKernelArg(kernels[layerNum], i, sizeof(cl_mem),
                         &HiddenLayer0OutputPipes[i]));
  }
#else
  // if not using channels, then pass global array pointers
  CHECK(clSetKernelArg(kernels[layerNum], 0, sizeof(cl_mem), &Hl0OutBuffers0));
  CHECK(clSetKernelArg(kernels[layerNum], 1, sizeof(cl_mem), &Hl0OutBuffers1));
  CHECK(clSetKernelArg(kernels[layerNum], 2, sizeof(cl_mem), &Hl0OutBuffers2));
  CHECK(clSetKernelArg(kernels[layerNum], 3, sizeof(cl_mem), &Hl0OutBuffers3));
  CHECK(clSetKernelArg(kernels[layerNum], 4, sizeof(cl_mem), &Hl0OutBuffers4));
  CHECK(clSetKernelArg(kernels[layerNum], 5, sizeof(cl_mem), &Hl0OutBuffers5));
  CHECK(clSetKernelArg(kernels[layerNum], 6, sizeof(cl_mem), &Hl0OutBuffers6));
  CHECK(clSetKernelArg(kernels[layerNum], 7, sizeof(cl_mem), &Hl0OutBuffers7));
#endif

  // set output buffer
  outputBuffer = clCreateBuffer(context, CL_MEM_WRITE_ONLY,
                                inputData.size() * OUTPUT_WIDTH * sizeof(float),
                                0, &status);
  CHECK(status);
  CHECK(clSetKernelArg(kernels[layerNum], 8, sizeof(cl_mem), &outputBuffer));

  // set weights
  weightBuffers[layerNum - 1] = clCreateBuffer(
      context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
      numberOfNeuronsOutput * numberOfInputsOutput * sizeof(float),
      outputLayerWeights, &status);
  CHECK(status);
  CHECK(clSetKernelArg(kernels[layerNum], 9, sizeof(cl_mem),
                       &weightBuffers[layerNum - 1]));

  // set bias
  biasBuffers[layerNum - 1] = clCreateBuffer(
      context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
      numberOfNeuronsHidden0 * sizeof(float), hiddenLayer0Bias, &status);
  CHECK(status);
  CHECK(clSetKernelArg(kernels[layerNum], 10, sizeof(cl_mem),
                       &biasBuffers[layerNum - 1]));

#ifdef LOCAL_BUFFERS
  CHECK(clSetKernelArg(kernels[layerNum], 11, sizeof(int),
                       &numberOfNeuronsOutput));

  // set total number of examples
  CHECK(clSetKernelArg(kernels[layerNum], 12, sizeof(int),
                       &totalNumberOfExamples));

#else
  inputBuffers[layerNum] =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     numberOfInputsOutput * sizeof(float), NULL, &status);
  CHECK(status);
  CHECK(clSetKernelArg(kernels[layerNum], 11, sizeof(cl_mem),
                       &inputBuffers[layerNum]));

  outputLayerSoftmaxBuffer =
      clCreateBuffer(context, CL_MEM_READ_WRITE,
                     numberOfNeuronsOutput * sizeof(float), NULL, &status);
  CHECK(status);
  CHECK(clSetKernelArg(kernels[layerNum], 12, sizeof(cl_mem),
                       &outputLayerSoftmaxBuffer));

  CHECK(clSetKernelArg(kernels[layerNum], 13, sizeof(int),
                       &numberOfNeuronsOutput));

  CHECK(clSetKernelArg(kernels[layerNum], 14, sizeof(int),
                       &numberOfInputsOutput));

  // set total number of examples
  CHECK(clSetKernelArg(kernels[layerNum], 15, sizeof(int),
                       &totalNumberOfExamples));

// CHECK(clSetKernelArg(kernels[layerNum], 16, sizeof(int), &repeat));
#endif

  // now start running stuff
  // --------------------------------------------------
  // Launch Kernels

  size_t size[3] = {1, 0, 0};

  cl_event inputLayerTimingEvent;
  cl_event hiddenLayerTimingEvent;
  cl_event outputLayerTimingEvent;

  for (int i = 0; i < NUM_LAYERS; i++) {
    cout << i << endl;

#ifdef SINGLE_QUEUE

    switch (i) {
    case 0:
      status =
          clEnqueueNDRangeKernel(commandQueues[0], kernels[i], 1, NULL, size,
                                 size, 0, NULL, &inputLayerTimingEvent);
      CHECK(status);
      break;
    case 1:
      status =
          clEnqueueNDRangeKernel(commandQueues[0], kernels[i], 1, NULL, size,
                                 size, 0, NULL, &hiddenLayerTimingEvent);
      CHECK(status);
      break;
    case 2:
      status =
          clEnqueueNDRangeKernel(commandQueues[0], kernels[i], 1, NULL, size,
                                 size, 0, NULL, &outputLayerTimingEvent);
      CHECK(status);
      break;
    default:
      cout << "Tried to enqueue invalid kernel!" << endl;
      exit(1);
    }

#else
    switch (i) {
    case 0:
      status =
          clEnqueueNDRangeKernel(commandQueues[i], kernels[i], 1, NULL, size,
                                 size, 0, NULL, &inputLayerTimingEvent);
      CHECK(status);
      break;
    case 1:
      status =
          clEnqueueNDRangeKernel(commandQueues[i], kernels[i], 1, NULL, size,
                                 size, 0, NULL, &hiddenLayerTimingEvent);
      CHECK(status);
      break;
    case 2:
      status =
          clEnqueueNDRangeKernel(commandQueues[i], kernels[i], 1, NULL, size,
                                 size, 0, NULL, &outputLayerTimingEvent);
      CHECK(status);
      break;
    default:
      cout << "Tried to enqueue invalid kernel!" << endl;
      exit(1);
    }
#endif
  }

#ifdef SINGLE_QUEUE
  CHECK(clFinish(commandQueues[0]));
#else
  for (int i = 0; i < NUM_LAYERS; i++) {
    CHECK(clFinish(commandQueues[i]));
  }
#endif

  // Read results
  //---------------------
  cout << "Reading results to host buffers...\n";

  float *outputAsArray = new float[inputData.size() * OUTPUT_WIDTH];

#ifdef SINGLE_QUEUE
  CHECK(clEnqueueReadBuffer(commandQueues[0], outputBuffer, CL_TRUE, 0,
                            sizeof(float) * inputData.size() * OUTPUT_WIDTH,
                            outputAsArray, 0, NULL, NULL));
#else
  CHECK(clEnqueueReadBuffer(commandQueues[2], outputBuffer, CL_TRUE, 0,
                            sizeof(float) * inputData.size() * OUTPUT_WIDTH,
                            outputAsArray, 0, NULL, NULL));
#endif

  // for (int i = 0; i < inputData.size() * OUTPUT_WIDTH; i++) {
  //   cout << outputAsArray[i] << ", ";
  // }

  for (int i = 0; i < inputData.size(); i++) {
    vector<float> row(OUTPUT_WIDTH);
    for (int j = 0; j < OUTPUT_WIDTH; j++) {
      row[j] = outputAsArray[i * OUTPUT_WIDTH + j];
    }
    outputData.push_back(row);
  }

  write_results("results");

  cl_ulong inputLayerStartTime;
  cl_ulong inputLayerEndTime;

  cl_ulong hiddenLayerStartTime;
  cl_ulong hiddenLayerEndTime;

  cl_ulong outputLayerStartTime;
  cl_ulong outputLayerEndTime;

// on cpu can use the nice event timing api
#if TARGET == CPU
  CHECK(clGetEventProfilingInfo(
      inputLayerTimingEvent, CL_PROFILING_COMMAND_START,
      sizeof(inputLayerStartTime), &inputLayerStartTime, NULL));

  CHECK(clGetEventProfilingInfo(inputLayerTimingEvent, CL_PROFILING_COMMAND_END,
                                sizeof(inputLayerEndTime), &inputLayerEndTime,
                                NULL));

  CHECK(clGetEventProfilingInfo(
      hiddenLayerTimingEvent, CL_PROFILING_COMMAND_START,
      sizeof(hiddenLayerStartTime), &hiddenLayerStartTime, NULL));

  CHECK(clGetEventProfilingInfo(
      hiddenLayerTimingEvent, CL_PROFILING_COMMAND_END,
      sizeof(hiddenLayerEndTime), &hiddenLayerEndTime, NULL));

  CHECK(clGetEventProfilingInfo(
      outputLayerTimingEvent, CL_PROFILING_COMMAND_START,
      sizeof(outputLayerStartTime), &outputLayerStartTime, NULL));

  CHECK(clGetEventProfilingInfo(
      outputLayerTimingEvent, CL_PROFILING_COMMAND_END,
      sizeof(outputLayerEndTime), &outputLayerEndTime, NULL));
#endif
// on FPGA have to parse profile.mon file
#if TARGET == FPGA

  ifstream profileMon("profile.mon");

  if (profileMon.good()) {

    string line;
    int numberOfLinesRead = 0;

    for (int lineNumber = 0; getline(profileMon, line); lineNumber++) {
      if (numberOfLinesRead >= 3) {
        throw "profile.mon has more than 3 lines.";
      }

      switch (lineNumber) {
      case 0:
        setStartAndEndTime(&inputLayerStartTime, &inputLayerEndTime, line);
        break;
      case 1:
        setStartAndEndTime(&hiddenLayerStartTime, &hiddenLayerEndTime, line);
        break;
      case 2:
        setStartAndEndTime(&outputLayerStartTime, &outputLayerEndTime, line);
        break;
      }
      numberOfLinesRead++;
    }

    profileMon.close();

    // move profile.mon to profile-<kernel name>-<date>.mon

    stringstream newNameBuffer;
    newNameBuffer << "profile-";
    newNameBuffer << openClFileName;

    time_t now = time(NULL);
    tm *timestamp = localtime(&now);
    char foo[24];

    if (strftime(foo, sizeof(foo), "%Y-%m-%d-%H:%M:%S", timestamp) > 0) {
      newNameBuffer << foo;
    }

    newNameBuffer << ".mon";

    string newName = newNameBuffer.str();
    rename("profile.mon", newName.c_str());

  } else {
    cout << "Unable to read profile.mon";
    profileMon.close();
  }

#endif

  double totalNS = outputLayerEndTime - inputLayerStartTime;
  double inputLayerDurationNS = inputLayerEndTime - inputLayerStartTime;
  double hiddenLayerDurationNS = hiddenLayerEndTime - hiddenLayerStartTime;
  double outputLayerDurationNS = outputLayerEndTime - outputLayerStartTime;

  cout << "------------------------  Execution timings "
          "------------------------\n";
  cout << "OpenCL total execution time: " << totalNS / 1000000.0 << " ms\n\n";

  cout << "\t"
       << "Input Layer execution time: " << inputLayerDurationNS / 1000000.0
       << " ms\n";
  cout << "\t"
       << "start: " << inputLayerStartTime << " end: " << inputLayerEndTime
       << "\n\n";

  cout << "\t"
       << "Hidden Layer execution time: " << hiddenLayerDurationNS / 1000000.0
       << " ms\n";
  cout << "\t"
       << "start: " << hiddenLayerStartTime << " end: " << hiddenLayerEndTime
       << "\n\n";

  cout << "\t"
       << "Input Layer execution time: " << outputLayerDurationNS / 1000000.0
       << " ms\n";
  cout << "\t"
       << "start: " << outputLayerStartTime << " end: " << outputLayerEndTime
       << "\n\n";

  cout << "--------------------------------------------"
          "------------------------\n";

  // output raw data as CSV row for easy pasting into spread sheet
  cout << "Spreadsheet Data:\n";
  // only kernel execution event data
  cout << openClFileName << "," << inputData.size() << /*"," << repeat << */ ","
       << totalNS << ","
       // ----------------- input layer  ----------------------
       << inputLayerStartTime << "," << inputLayerEndTime << ","
       << inputLayerStartTime - inputLayerStartTime << ","
       << inputLayerEndTime - inputLayerStartTime << "," << inputLayerDurationNS
       << ","
       // ------------------ hidden layer ---------------------
       << hiddenLayerStartTime << "," << hiddenLayerEndTime << ","
       << hiddenLayerStartTime - inputLayerStartTime << ","
       << hiddenLayerEndTime - inputLayerStartTime << ","
       << hiddenLayerDurationNS << ","
       // ------------------- output layer ----------------------
       << outputLayerStartTime << "," << outputLayerEndTime << ","
       << outputLayerStartTime - inputLayerStartTime << ","
       << outputLayerEndTime - inputLayerStartTime << ","
       << outputLayerDurationNS << endl;

  // Post-processing
  //---------------------

  // release input buffers
  for (int i = 0; i < NUM_LAYERS; i++) {
    clReleaseMemObject(inputBuffers[i]);
  }

  for (int i = 0; i < NUM_LAYERS - 2; i++) {
    clReleaseMemObject(weightBuffers[i]);
  }

  // release output buffer
  clReleaseMemObject(outputBuffer);

  // release pipes
  for (int i = 0; i < 4; i++) {
    clReleaseMemObject(InputLayerOutputPipes[i]);
  }
  for (int i = 0; i < 8; i++) {
    clReleaseMemObject(HiddenLayer0OutputPipes[i]);
  }
  // for (int i = 0; i < 3; i++) {
  //   clReleaseMemObject(HiddenLayer1OutputPipes[i]);
  // }

  // release kernels
  for (int i = 0; i < NUM_LAYERS; i++) {
    clReleaseKernel(kernels[i]);
  }

  clReleaseProgram(program);
  clReleaseContext(context);

  return 0;
}

void setStartAndEndTime(cl_ulong *start, cl_ulong *end, string line) {

  stringstream ss(line);
  string token;

  for (int fieldIdx = 0; getline(ss, token, ','); fieldIdx++) {
    switch (fieldIdx) {
    case 3:
      *start = stoul(token);
      break;
    case 4:
      *end = stoul(token);
      break;
    }
  }
}

void write_results(string resultsDir) {
  stringstream buffer;
  buffer << resultsDir << "/results-oclnn-";

  time_t now = time(NULL);
  tm *timestamp = localtime(&now);
  char foo[24];

  if (strftime(foo, sizeof(foo), "%Y-%m-%d-%H:%M:%S", timestamp) > 0) {
    buffer << foo;
  }

  const string filename = buffer.str();

  FILE *results = fopen(filename.c_str(), "w");

  for (int i = 0; i < inputData.size(); i++) {

    for (int x = 0; x < inputData[i].size(); x++) {
      fprintf(results, "%f, ", inputData[i][x]);
    }
    fprintf(results, " ---> ");
    for (int x = 0; x < outputData[i].size(); x++) {
      fprintf(results, "%f, ", outputData[i][x]);
    }
    fprintf(results, "\n");
  }
}

vector<vector<float>> generateFakeIrisData(vector<vector<float>> *inputData,
                                           int numberOfRecords) {

  int rowLen = inputData->at(0).size();

  vector<vector<float>> cols(rowLen);

  for (int i = 0; i < cols.size(); i++) {
    cols[i] = vector<float>(inputData->size());
  }

  for (int rowIdx = 0; rowIdx < inputData->size(); rowIdx++) {
    for (int colIdx = 0; colIdx < cols.size(); colIdx++) {
      cols[colIdx][rowIdx] = inputData->at(rowIdx)[colIdx];
    }
  }

  vector<vector<float>> generatedCols(rowLen);

  for (int i = 0; i < cols.size(); i++) {
    generatedCols[i] = generateColumn(&cols[i], numberOfRecords);
  }

  vector<vector<float>> rows(numberOfRecords);

  for (int rowIdx = 0; rowIdx < numberOfRecords; rowIdx++) {

    vector<float> row(4);

    for (int colIdx = 0; colIdx < cols.size(); colIdx++) {
      row[colIdx] = generatedCols[colIdx][rowIdx];
    }

    rows[rowIdx] = row;
  }

  return rows;
}

vector<float> generateColumn(vector<float> *sampleData, int numberOfRecords) {

  float max = *max_element(sampleData->begin(), sampleData->end());
  float min = *min_element(sampleData->begin(), sampleData->end());

  vector<float> generated(numberOfRecords);
  generated.reserve(numberOfRecords);

  std::random_device rd;
  std::mt19937 mt(rd());
  std::uniform_real_distribution<float> dist(min, max);

  for (int i = 0; i < numberOfRecords; i++) {
    generated[i] = dist(mt);
  }

  return generated;
}

unsigned char *load_file(const char *filename, size_t *size_ret) {
  FILE *fp;
  int len;
  const size_t CHUNK_SIZE = 1000000;
  unsigned char *result;
  size_t r = 0;
  size_t w = 0;
  fp = fopen(filename, "rb");
  if (!fp)
    return 0;
  // Obtain file size.
  fseek(fp, 0, SEEK_END);
  len = ftell(fp);
  // Go to the beginning.
  fseek(fp, 0, SEEK_SET);
  // Allocate memory for the file data.
  result = (unsigned char *)malloc(len + CHUNK_SIZE);
  if (!result) {
    fclose(fp);
    return 0;
  }
  // Read file.
  while (0 < (r = fread(result + w, 1, CHUNK_SIZE, fp))) {
    w += r;
  }
  fclose(fp);
  *size_ret = w;
  return result;
}

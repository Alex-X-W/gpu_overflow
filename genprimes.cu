//#define DEBUG

#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>

#ifdef DEBUG
cudaError_t status;
void checkCuda(cudaError_t& status) {
    status = cudaGetLastError();
    if (status == cudaSuccess) {
        fprintf(stderr, "Success!\n");
    } else {
        fprintf(stderr, "CUDA error: %s\n", cudaGetErrorString(status));
        exit(-1);
    }
}
#endif

__global__ void CUDACross(bool *candidates, int size){
    for (int idx = blockIdx.x*blockDim.x + threadIdx.x; idx < size/2 + 1; idx += blockDim.x * gridDim.x) {
        int multiplier = idx + 2;
        int check = multiplier * multiplier; // bang when `multiplier` reaches ceil(sqrt(2^31)) = 46341
        //if (candidates[multiplier-2]) {    // which is when `N` gets to (46341-2-1)*2 + 2 = 92678
            while (check < size + 2){
                candidates[check - 2] = false;
                check += multiplier;
            }
        //}
    }
}

void init(bool *candidates, int size){
    for (int i = 0; i<size; i++)
        candidates[i] = true;
}

int main(int argc, char* argv[]) {
    /*if (argc != 2 || atoi(argv[1]) < 2 || atoi(argv[1]) > 1000000) {
        fprintf(stderr, "bad input\nusage: $ ./seqgenprimes N\nwhere N is in [2, 1000000]");
        exit(-1);
    }*/
    int N = atoi(argv[1]);
    int size = N - 1;

    bool* candidates = new bool[size];

    init(candidates, size);

    int deviceNum = 0;
    cudaSetDevice(deviceNum);
    struct cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, deviceNum);

    int dimBlock = prop.maxThreadsPerBlock / 4;
    int dimGrid = prop.multiProcessorCount * 32;

#ifdef DEBUG
    fprintf(stderr, "maxThreadsPerBlock is %d\n", prop.maxThreadsPerBlock);
    fprintf(stderr, "maxThreadsPerMultiProcessor is %d\n", prop.maxThreadsPerMultiProcessor);
    fprintf(stderr, "totalGlobalMem is %d\n", prop.totalGlobalMem);
#endif

    //Initialize arrays
    bool *gpudata;

    //Allocate memory
    cudaMalloc((void**)&gpudata, sizeof(bool)*size);
#ifdef DEBUG
    fprintf(stderr, "checking cudaMalloc()...\n");
    checkCuda(status);
#endif

    //Copy to GPU
    cudaMemcpy(gpudata, candidates, sizeof(bool)*size, cudaMemcpyHostToDevice);
#ifdef DEBUG
    fprintf(stderr, "checking cudaMemcpy() host to device...\n");
    checkCuda(status);
#endif

    //Kernel call on the GPU
//    CUDACross<<<bNum, tNum>>>(gpudata, size, bNum, tNum);
    CUDACross<<<dimGrid, dimBlock>>>(gpudata, size);
//    CUDACross<<<dimGrid, dimBlock>>>(gpudata, size, N);
#ifdef DEBUG
    fprintf(stderr, "checking kernel...\n");
    checkCuda(status);
#endif

    //Copy from GPU back onto host
    cudaMemcpy(candidates, gpudata, sizeof(bool)*size, cudaMemcpyDeviceToHost);
#ifdef DEBUG
    fprintf(stderr, "checking cudaMemcpy() device to host...\n");
    checkCuda(status);
#endif

    //Free the memory on the GPU
    cudaFree(gpudata);

    char filename[20];
    sprintf(filename, "%d.txt", N);
    FILE *fp = fopen(filename, "w");
    fprintf(fp, "%d ", 2);
#ifdef DEBUG
    fprintf(stderr, "%d ", 2);
#endif
    for (int i = 1; i < size; ++i) {
        if (candidates[i]) fprintf(fp, "%d ", i+2);
#ifdef DEBUG
        if (candidates[i]) fprintf(stderr, "%d ", i+2);
#endif
    }
    return 0;
}

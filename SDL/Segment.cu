#include "Segment.cuh"

///FIXME:NOTICE THE NEW maxPixelSegments!

void SDL::createSegmentsInExplicitMemory(struct segments& segmentsInGPU, unsigned int nMemoryLocations, uint16_t nLowerModules, unsigned int maxPixelSegments, cudaStream_t stream)
{
    //FIXME:Since the number of pixel segments is 10x the number of regular segments per module, we need to provide
    //extra memory to the pixel segments
#ifdef CACHE_ALLOC
    int dev;
    cudaGetDevice(&dev);
    segmentsInGPU.mdIndices = (unsigned int*)cms::cuda::allocate_device(dev,nMemoryLocations*4 *sizeof(unsigned int),stream);
    segmentsInGPU.innerLowerModuleIndices = (uint16_t*)cms::cuda::allocate_device(dev,nMemoryLocations*2 *sizeof(uint16_t),stream);
    segmentsInGPU.nSegments = (int*)cms::cuda::allocate_device(dev, (nLowerModules + 1) *sizeof(int),stream);
    segmentsInGPU.totOccupancySegments = (int*)cms::cuda::allocate_device(dev, (nLowerModules + 1) *sizeof(unsigned int),stream);
    segmentsInGPU.dPhis = (FPX*)cms::cuda::allocate_device(dev,nMemoryLocations*6 *sizeof(FPX),stream);
    segmentsInGPU.ptIn = (float*)cms::cuda::allocate_device(dev, maxPixelSegments * 8 *sizeof(float),stream);
    segmentsInGPU.superbin = (int*)cms::cuda::allocate_device(dev,(maxPixelSegments) *sizeof(int),stream);
    segmentsInGPU.pixelType = (int8_t*)cms::cuda::allocate_device(dev,(maxPixelSegments) *sizeof(int8_t),stream);
    segmentsInGPU.isQuad = (char*)cms::cuda::allocate_device(dev,(maxPixelSegments) *sizeof(char),stream);
    segmentsInGPU.isDup = (bool*)cms::cuda::allocate_device(dev,(maxPixelSegments) *sizeof(bool),stream);
    segmentsInGPU.score = (float*)cms::cuda::allocate_device(dev,(maxPixelSegments) *sizeof(float),stream);
    segmentsInGPU.charge = (int*)cms::cuda::allocate_device(dev, maxPixelSegments * sizeof(int), stream);
    segmentsInGPU.seedIdx = (unsigned int*)cms::cuda::allocate_device(dev, maxPixelSegments * sizeof(unsigned int), stream);
    segmentsInGPU.circleCenterX = (float*)cms::cuda::allocate_device(dev, maxPixelSegments * sizeof(float), stream);
    segmentsInGPU.circleCenterY = (float*)cms::cuda::allocate_device(dev, maxPixelSegments * sizeof(float), stream);
    segmentsInGPU.circleRadius = (float*)cms::cuda::allocate_device(dev, maxPixelSegments * sizeof(float), stream);
    segmentsInGPU.partOfPT5 = (bool*)cms::cuda::allocate_device(dev, maxPixelSegments * sizeof(bool), stream);
    segmentsInGPU.pLSHitsIdxs = (uint4*)cms::cuda::allocate_device(dev, maxPixelSegments * sizeof(uint4), stream);
    segmentsInGPU.nMemoryLocations = (unsigned int*)cms::cuda::allocate_device(dev, sizeof(unsigned int), stream);
#else
    cudaMalloc(&segmentsInGPU.mdIndices, nMemoryLocations * 4 * sizeof(unsigned int));
    cudaMalloc(&segmentsInGPU.innerLowerModuleIndices, nMemoryLocations * 2 * sizeof(uint16_t));
    cudaMalloc(&segmentsInGPU.nSegments, (nLowerModules + 1) * sizeof(int));
    cudaMalloc(&segmentsInGPU.totOccupancySegments, (nLowerModules + 1) * sizeof(int));
    cudaMalloc(&segmentsInGPU.dPhis, nMemoryLocations * 6 *sizeof(FPX));
    cudaMalloc(&segmentsInGPU.ptIn, maxPixelSegments * 8*sizeof(float));
    cudaMalloc(&segmentsInGPU.superbin, (maxPixelSegments )*sizeof(int));
    cudaMalloc(&segmentsInGPU.pixelType, (maxPixelSegments )*sizeof(int8_t));
    cudaMalloc(&segmentsInGPU.isQuad, (maxPixelSegments )*sizeof(char));
    cudaMalloc(&segmentsInGPU.isDup, (maxPixelSegments )*sizeof(bool));
    cudaMalloc(&segmentsInGPU.score, (maxPixelSegments )*sizeof(float));
    cudaMalloc(&segmentsInGPU.charge, maxPixelSegments * sizeof(int));
    cudaMalloc(&segmentsInGPU.seedIdx, maxPixelSegments * sizeof(unsigned int));
    cudaMalloc(&segmentsInGPU.circleCenterX, maxPixelSegments * sizeof(float));
    cudaMalloc(&segmentsInGPU.circleCenterY, maxPixelSegments * sizeof(float));
    cudaMalloc(&segmentsInGPU.circleRadius, maxPixelSegments * sizeof(float));
    cudaMalloc(&segmentsInGPU.partOfPT5, maxPixelSegments * sizeof(bool));
    cudaMalloc(&segmentsInGPU.pLSHitsIdxs, maxPixelSegments * sizeof(uint4));
    cudaMalloc(&segmentsInGPU.nMemoryLocations, sizeof(unsigned int));
#endif
    segmentsInGPU.outerLowerModuleIndices = segmentsInGPU.innerLowerModuleIndices + nMemoryLocations;
    segmentsInGPU.innerMiniDoubletAnchorHitIndices = segmentsInGPU.mdIndices + nMemoryLocations * 2;
    segmentsInGPU.outerMiniDoubletAnchorHitIndices = segmentsInGPU.mdIndices + nMemoryLocations * 3;

    segmentsInGPU.dPhiMins = segmentsInGPU.dPhis + nMemoryLocations;
    segmentsInGPU.dPhiMaxs = segmentsInGPU.dPhis + nMemoryLocations * 2;
    segmentsInGPU.dPhiChanges = segmentsInGPU.dPhis + nMemoryLocations * 3;
    segmentsInGPU.dPhiChangeMins = segmentsInGPU.dPhis + nMemoryLocations * 4;
    segmentsInGPU.dPhiChangeMaxs = segmentsInGPU.dPhis + nMemoryLocations * 5;

    segmentsInGPU.ptErr  = segmentsInGPU.ptIn + maxPixelSegments;
    segmentsInGPU.px     = segmentsInGPU.ptIn + maxPixelSegments * 2;
    segmentsInGPU.py     = segmentsInGPU.ptIn + maxPixelSegments * 3;
    segmentsInGPU.pz     = segmentsInGPU.ptIn + maxPixelSegments * 4;
    segmentsInGPU.etaErr = segmentsInGPU.ptIn + maxPixelSegments * 5;
    segmentsInGPU.eta    = segmentsInGPU.ptIn + maxPixelSegments * 6;
    segmentsInGPU.phi    = segmentsInGPU.ptIn + maxPixelSegments * 7;

    cudaMemsetAsync(segmentsInGPU.nSegments,0, (nLowerModules + 1) * sizeof(int),stream);
    cudaMemsetAsync(segmentsInGPU.totOccupancySegments,0, (nLowerModules + 1) * sizeof(int),stream);
    cudaMemsetAsync(segmentsInGPU.partOfPT5, false, maxPixelSegments * sizeof(bool),stream);
    cudaMemsetAsync(segmentsInGPU.pLSHitsIdxs, 0, maxPixelSegments * sizeof(uint4),stream);
    cudaMemsetAsync(segmentsInGPU.nMemoryLocations, nMemoryLocations, sizeof(unsigned int), stream);
    cudaStreamSynchronize(stream);
}

SDL::segments::segments()
{
    superbin = nullptr;
    pixelType = nullptr;
    isQuad = nullptr;
    isDup = nullptr;
    score = nullptr;
    circleRadius = nullptr;
    charge = nullptr;
    seedIdx = nullptr;
    circleCenterX = nullptr;
    circleCenterY = nullptr;
    mdIndices = nullptr;
    innerLowerModuleIndices = nullptr;
    outerLowerModuleIndices = nullptr;
    innerMiniDoubletAnchorHitIndices = nullptr;
    outerMiniDoubletAnchorHitIndices = nullptr;

    nSegments = nullptr;
    totOccupancySegments = nullptr;
    dPhis = nullptr;
    dPhiMins = nullptr;
    dPhiMaxs = nullptr;
    dPhiChanges = nullptr;
    dPhiChangeMins = nullptr;
    dPhiChangeMaxs = nullptr;
    partOfPT5 = nullptr;
    pLSHitsIdxs = nullptr;
}

SDL::segments::~segments()
{
}

void SDL::segments::freeMemoryCache()
{
    int dev;
    cudaGetDevice(&dev);
    cms::cuda::free_device(dev,mdIndices);
    cms::cuda::free_device(dev,innerLowerModuleIndices);
    cms::cuda::free_device(dev,dPhis);
    cms::cuda::free_device(dev,ptIn);
    cms::cuda::free_device(dev,nSegments);
    cms::cuda::free_device(dev,totOccupancySegments);
    cms::cuda::free_device(dev, charge);
    cms::cuda::free_device(dev, seedIdx);
    cms::cuda::free_device(dev,superbin);
    cms::cuda::free_device(dev,pixelType);
    cms::cuda::free_device(dev,isQuad);
    cms::cuda::free_device(dev,isDup);
    cms::cuda::free_device(dev,score);
    cms::cuda::free_device(dev, circleCenterX);
    cms::cuda::free_device(dev, circleCenterY);
    cms::cuda::free_device(dev, circleRadius);
    cms::cuda::free_device(dev, partOfPT5);
    cms::cuda::free_device(dev, pLSHitsIdxs);
    cms::cuda::free_device(dev, nMemoryLocations);
}

void SDL::segments::freeMemory(cudaStream_t stream)
{
    cudaFree(mdIndices);
    cudaFree(innerLowerModuleIndices);
    cudaFree(nSegments);
    cudaFree(totOccupancySegments);
    cudaFree(dPhis);
    cudaFree(ptIn);
    cudaFree(superbin);
    cudaFree(pixelType);
    cudaFree(isQuad);
    cudaFree(isDup);
    cudaFree(score);
    cudaFree(charge);
    cudaFree(seedIdx);
    cudaFree(circleCenterX);
    cudaFree(circleCenterY);
    cudaFree(circleRadius);
    cudaFree(partOfPT5);
    cudaFree(pLSHitsIdxs);
    cudaFree(nMemoryLocations);
}

void SDL::printSegment(struct SDL::segments& segmentsInGPU, struct SDL::miniDoublets& mdsInGPU, struct SDL::hits& hitsInGPU, struct SDL::modules& modulesInGPU, unsigned int segmentIndex)
{
    unsigned int innerMDIndex = segmentsInGPU.mdIndices[segmentIndex * 2];
    unsigned int outerMDIndex = segmentsInGPU.mdIndices[segmentIndex * 2 + 1];
    std::cout<<std::endl;
    std::cout<<"sg_dPhiChange : "<<__H2F(segmentsInGPU.dPhiChanges[segmentIndex]) << std::endl<<std::endl;

    std::cout << "Inner Mini-Doublet" << std::endl;
    std::cout << "------------------------------" << std::endl;
    {
        IndentingOStreambuf indent(std::cout);
        printMD(mdsInGPU, hitsInGPU, modulesInGPU, innerMDIndex);
    }
    std::cout<<std::endl<<" Outer Mini-Doublet" <<std::endl;
    std::cout << "------------------------------" << std::endl;
    {
        IndentingOStreambuf indent(std::cout);
        printMD(mdsInGPU, hitsInGPU, modulesInGPU, outerMDIndex);
    }
}
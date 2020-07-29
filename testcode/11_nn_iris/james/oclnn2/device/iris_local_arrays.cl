// activation function 
#define RELU(x) x > 0 ? x : 0

__kernel void inputLayer(
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) ILOutPipe0,
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) ILOutPipe1,
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) ILOutPipe2,
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) ILOutPipe3, 
                        __global float * restrict inputs,       
                        int numberOfNeurons,
                        int totalNumberOfExamples)
{   
    // loop over all input examples
    for(int currentExample = 0; currentExample < totalNumberOfExamples; currentExample++)
    {
        // write input example to appropriate pipe - used to be done in a loop but now has been unrolled
        float output0 = inputs[currentExample * numberOfNeurons]; 
        write_pipe(ILOutPipe0, &output0);           

        float output1 = inputs[currentExample * numberOfNeurons + 1]; 
        write_pipe(ILOutPipe1, &output1);

        float output2 = inputs[currentExample * numberOfNeurons + 2]; 
        write_pipe(ILOutPipe2, &output2);

        float output3 = inputs[currentExample * numberOfNeurons + 3]; 
        write_pipe(ILOutPipe3, &output3);          
    }
}

__kernel void hiddenLayer0(
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) ILOutPipe0,
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) ILOutPipe1,
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) ILOutPipe2,
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) ILOutPipe3,
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe0,
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe1,
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe2,
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe3,
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe4,
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe5,
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe6,
                        __write_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe7,
                        __global float * restrict weightsIn,
                        __global float * restrict biasIn,
                        int numberOfNeurons, 
                        int totalNumberOfExamples)
{
    // move layer parameters into private memory (on chip memory on FPGA)
    float weights[32];
    #pragma unroll
    for(int i = 0; i < 32; i++){
        weights[i] = weightsIn[i];
    }    

    float bias[8];
    #pragma unroll
    for(int i = 0; i < 8; i++){
        bias[i] = biasIn[i];
    }

    // create array to store layer inputs - used to be in global memory 
    float layerInputs[4]; 

    // loop over all examples
    for(int currentExample = 0; currentExample < totalNumberOfExamples; currentExample++)
    {
        // read inputs
        read_pipe(ILOutPipe0, &layerInputs[0]);
        read_pipe(ILOutPipe1, &layerInputs[1]);
        read_pipe(ILOutPipe2, &layerInputs[2]);
        read_pipe(ILOutPipe3, &layerInputs[3]);        

        // now do work for each neuron in layer - used to be in loop but it has been unrolled

        float dot_prod0 = 0;
        
        // Compute weight * input for each input then sum together to produce
        // this neurons output. Hopefully OpenCL will do something clever with 
        // this loop. 
        #pragma unroll
        for(int j = 0; j < 4; j++)
        {
            int weightIndex = numberOfNeurons * j; 
            dot_prod0 += weights[weightIndex] * layerInputs[j];
        }      

        float output0 = RELU(dot_prod0 + bias[0]);
        write_pipe(HL0OutPipe0, &output0);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        float dot_prod1 = 0;
        
        // Compute weight * input for each input then sum together to produce
        // this neurons output. Hopefully OpenCL will do something clever with 
        // this loop. 
        #pragma unroll
        for(int j = 0; j < 4; j++)
        {
            int weightIndex = numberOfNeurons * j + 1; 
            dot_prod1 += weights[weightIndex] * layerInputs[j];
        }      

        float output1 = RELU(dot_prod1 + bias[1]);
        write_pipe(HL0OutPipe1, &output1);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        float dot_prod2 = 0;
        
        // Compute weight * input for each input then sum together to produce
        // this neurons output. Hopefully OpenCL will do something clever with 
        // this loop. 
        #pragma unroll
        for(int j = 0; j < 4; j++)
        {
            int weightIndex = numberOfNeurons * j + 2; 
            dot_prod2 += weights[weightIndex] * layerInputs[j];
        }     

        float output2 = RELU(dot_prod2 + bias[2]);
        write_pipe(HL0OutPipe2, &output2); 

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        float dot_prod3 = 0;
        
        // Compute weight * input for each input then sum together to produce
        // this neurons output. Hopefully OpenCL will do something clever with 
        // this loop. 
        #pragma unroll
        for(int j = 0; j < 4; j++)
        {
            int weightIndex = numberOfNeurons * j + 3; 
            dot_prod3 += weights[weightIndex] * layerInputs[j];
        }      

        float output3 = RELU(dot_prod3 + bias[3]);
        write_pipe(HL0OutPipe3, &output3);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        float dot_prod4 = 0;
        
        // Compute weight * input for each input then sum together to produce
        // this neurons output. Hopefully OpenCL will do something clever with 
        // this loop. 
        #pragma unroll
        for(int j = 0; j < 4; j++)
        {
            int weightIndex = numberOfNeurons * j + 4; 
            dot_prod4 += weights[weightIndex] * layerInputs[j];
        }      

        float output4 = RELU(dot_prod4 + bias[4]);
        write_pipe(HL0OutPipe4, &output4);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        float dot_prod5 = 0;
        
        // Compute weight * input for each input then sum together to produce
        // this neurons output. Hopefully OpenCL will do something clever with 
        // this loop. 
        #pragma unroll
        for(int j = 0; j < 4; j++)
        {
            int weightIndex = numberOfNeurons * j + 5; 
            dot_prod5 += weights[weightIndex] * layerInputs[j];
        }      

        float output5 = RELU(dot_prod5 + bias[5]);
        write_pipe(HL0OutPipe5, &output5);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        float dot_prod6 = 0;
        
        // Compute weight * input for each input then sum together to produce
        // this neurons output. Hopefully OpenCL will do something clever with 
        // this loop. 
        #pragma unroll
        for(int j = 0; j < 4; j++)
        {
            int weightIndex = numberOfNeurons * j + 6; 
            dot_prod6 += weights[weightIndex] * layerInputs[j];
        }      

        float output6 = RELU(dot_prod6 + bias[6]);
        write_pipe(HL0OutPipe6, &output6);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        float dot_prod7 = 0;
        
        // Compute weight * input for each input then sum together to produce
        // this neurons output. Hopefully OpenCL will do something clever with 
        // this loop. 
        #pragma unroll
        for(int j = 0; j < 4; j++)
        {
            int weightIndex = numberOfNeurons * j + 7; 
            dot_prod7 += weights[weightIndex] * layerInputs[j];
        }      

        float output7 = RELU(dot_prod7 + bias[7]);
        write_pipe(HL0OutPipe7, &output7);  
    }
}

__kernel void outputLayer(
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe0,
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe1,
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe2,
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe3,
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe4,
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe5,
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe6,
                        __read_only pipe float __attribute__((blocking)) __attribute__((depth(1))) HL0OutPipe7,
                        __global float * restrict outputs,
                        __global float * restrict weightsIn,
                        __global float * restrict biasIn,
                        int numberOfNeurons,
                        int totalNumberOfExamples)  
{

    // move layer parameters into private memory (on chip memory on FPGA)
    float weights[24];   
    #pragma unroll 
    for(int i = 0; i < 24; i++){
        weights[i] = weightsIn[i];
    }

    float bias[4];
    #pragma unroll
    for(int i = 0; i < 4; i++){
        bias[i] = biasIn[i];
    }
    
    // declare local arrays to hold inputs and values to be softmaxed
    float layerInputs[8];
    float softmaxBuffer[3];

    // loop over all input examples
    for(int currentExample = 0; currentExample < totalNumberOfExamples; currentExample++)
    {   
        // read inputs 
        read_pipe(HL0OutPipe0, &layerInputs[0]);
        read_pipe(HL0OutPipe1, &layerInputs[1]);
        read_pipe(HL0OutPipe2, &layerInputs[2]);
        read_pipe(HL0OutPipe3, &layerInputs[3]);
        read_pipe(HL0OutPipe4, &layerInputs[4]);
        read_pipe(HL0OutPipe5, &layerInputs[5]);
        read_pipe(HL0OutPipe6, &layerInputs[6]);
        read_pipe(HL0OutPipe7, &layerInputs[7]);

        // do each neurons work - used to be in loop        
    
        float dot_prod0 = 0;
        
        // Compute weight * input for each input then sum together to produce
        // this neurons output. Hopefully OpenCL will do something clever with 
        // this loop. 
        #pragma unroll
        for(int j = 0; j < 8; j++)
        {
            int weightIndex = numberOfNeurons * j;
            dot_prod0 += weights[weightIndex] * layerInputs[j];
        }      

        float output0 = dot_prod0 + bias[0];
        
        softmaxBuffer[0] = output0;
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        float dot_prod1 = 0;
        
        // Compute weight * input for each input then sum together to produce
        // this neurons output. Hopefully OpenCL will do something clever with 
        // this loop. 
        #pragma unroll
        for(int j = 0; j < 8; j++)
        {
            int weightIndex = numberOfNeurons * j + 1;
            dot_prod1 += weights[weightIndex] * layerInputs[j];
        }      

        float output1 = dot_prod1 + bias[1];
        
        softmaxBuffer[1] = output1;

        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        float dot_prod2 = 0;
        
        // Compute weight * input for each input then sum together to produce
        // this neurons output. Hopefully OpenCL will do something clever with 
        // this loop. 
        #pragma unroll
        for(int j = 0; j < 8; j++)
        {
            int weightIndex = numberOfNeurons * j + 2; 
            dot_prod2 += weights[weightIndex] * layerInputs[j];
        }      

        float output2 = dot_prod2 + bias[2];
                        
        softmaxBuffer[2] = output2;


        /////////////////////////////////////////////////   PREFORM SOFTMAX   ///////////////////////////////////////////////////////////////////


        // now preform softmax over last set of outputs
        // find maximum        
        float m = softmaxBuffer[0];
        for (int i = 0; i < numberOfNeurons; i++) {
            if (softmaxBuffer[i] > m) {
                m = softmaxBuffer[i];
            }
        }

        // calculate sum
        float sum = 0.0;
        for (int i = 0; i < numberOfNeurons; i++) {
            sum += exp(softmaxBuffer[i] - m);
        }
        
        float offset = m + log(sum);
        for (int i = 0; i < numberOfNeurons; i++) {
            outputs[currentExample * numberOfNeurons + i] = exp(softmaxBuffer[i] - offset);
        }        
    }
}


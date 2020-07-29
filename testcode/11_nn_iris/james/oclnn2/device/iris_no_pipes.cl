// Provided by Dr S. W. Nabi for use in evaluation

// activation function
#define RELU(x) x > 0 ? x : 0

__kernel void inputLayer(
                        __global float * restrict ILOutPipe0,
                        __global float * restrict ILOutPipe1,
                        __global float * restrict ILOutPipe2,
                        __global float * restrict ILOutPipe3, 
                        __global float * restrict inputs,       
                        int numberOfNeurons,
                        int totalNumberOfExamples)
{
        // loop over all input examples 
        for(int currentExample = 0; currentExample < totalNumberOfExamples; currentExample++)
        {
            // loop over neurons
            #pragma unroll
            for(int i = 0; i < numberOfNeurons; i++)
            {
                float output = inputs[currentExample * numberOfNeurons + i]; 

                // write outputs to memory buffers
                switch(i){
                    case 0:                     
                        ILOutPipe0[currentExample] = output;
                        break;
                    case 1:
                        ILOutPipe1[currentExample] = output;
                        break;
                    case 2: 
                        ILOutPipe2[currentExample] = output;
                        break;
                    case 3: 
                        ILOutPipe3[currentExample] = output;
                        break;
                    default:
                        break;
                }           
            }
        }
}

__kernel void hiddenLayer0(
                        __global float * restrict ILOutPipe0,
                        __global float * restrict ILOutPipe1,
                        __global float * restrict ILOutPipe2,
                        __global float * restrict ILOutPipe3,
                        __global float * restrict HL0OutPipe0,
                        __global float * restrict HL0OutPipe1,
                        __global float * restrict HL0OutPipe2,
                        __global float * restrict HL0OutPipe3,
                        __global float * restrict HL0OutPipe4,
                        __global float * restrict HL0OutPipe5,
                        __global float * restrict HL0OutPipe6,
                        __global float * restrict HL0OutPipe7,
                        __global float * restrict weights,
                        __global float * restrict bias,
                        __global float * restrict layerInputs, 
                        int numberOfNeurons, 
                        int numberOfInputs,
                        int totalNumberOfExamples)
{
        // loop over all input examples
        for(int currentExample = 0; currentExample < totalNumberOfExamples; currentExample++)
        {
            // read inputs
            layerInputs[0] = ILOutPipe0[currentExample];
            layerInputs[1] = ILOutPipe1[currentExample];
            layerInputs[2] = ILOutPipe2[currentExample];
            layerInputs[3] = ILOutPipe3[currentExample];
            
            // loop over neurons in this layer
            #pragma unroll
            for(int i = 0; i < numberOfNeurons; i++)
            {
                float dot_prod = 0;
                
                // Compute weight * input for each input then sum together to produce
                // this neurons output. Hopefully OpenCL will do something clever with 
                // this loop. 
                #pragma unroll
                for(int j = 0; j < numberOfInputs; j++)
                {
                    int weightIndex = numberOfNeurons * j + i; //numberOfInputs * i + j;
                    dot_prod += weights[weightIndex] * layerInputs[j];
                }      

                float val    = dot_prod + bias[i];
                float output =  RELU(val);

                // write outputs to memory buffers
                switch(i){
                    case 0:
                        HL0OutPipe0[currentExample] = output;
                        break;
                    case 1:
                        HL0OutPipe1[currentExample] = output;
                        break;
                    case 2: 
                        HL0OutPipe2[currentExample] = output;
                        break;
                    case 3: 
                        HL0OutPipe3[currentExample] = output;
                        break;
                    case 4:
                        HL0OutPipe4[currentExample] = output;
                        break;
                    case 5:
                        HL0OutPipe5[currentExample] = output;
                        break;
                    case 6: 
                        HL0OutPipe6[currentExample] = output;
                        break;
                    case 7: 
                        HL0OutPipe7[currentExample] = output;
                        break;
                    default:
                        break;
                } 
            } 
        } 
}

__kernel void outputLayer(
                        __global float * restrict HL0OutPipe0,
                        __global float * restrict HL0OutPipe1,
                        __global float * restrict HL0OutPipe2,
                        __global float * restrict HL0OutPipe3,
                        __global float * restrict HL0OutPipe4,
                        __global float * restrict HL0OutPipe5,
                        __global float * restrict HL0OutPipe6,
                        __global float * restrict HL0OutPipe7,
                        __global float * restrict outputs,
                        __global float * restrict weights,
                        __global float * restrict bias,
                        __global float * restrict layerInputs,
                        __global float * restrict softmaxBuffer,
                        int numberOfNeurons,
                        int numberOfInputs,
                        int totalNumberOfExamples)
{

        // loop over all input examples
        for(int currentExample = 0; currentExample < totalNumberOfExamples; currentExample++)
        {   
            // read inputs 
            layerInputs[0] = HL0OutPipe0[currentExample]; 
            layerInputs[1] = HL0OutPipe1[currentExample];
            layerInputs[2] = HL0OutPipe2[currentExample];
            layerInputs[3] = HL0OutPipe3[currentExample];
            layerInputs[4] = HL0OutPipe4[currentExample];
            layerInputs[5] = HL0OutPipe5[currentExample];
            layerInputs[6] = HL0OutPipe6[currentExample];
            layerInputs[7] = HL0OutPipe7[currentExample];    

            // loop over neurons
            #pragma unroll
            for(int i = 0; i < numberOfNeurons; i++)
            {
                float dot_prod = 0;
                
                // Compute weight * input for each input then sum together to produce
                // this neurons output. Hopefully OpenCL will do something clever with 
                // this loop. 
                #pragma unroll
                for(int j = 0; j < numberOfInputs; j++)
                {
                    int weightIndex = numberOfNeurons * j + i; //numberOfInputs * i + j;
                    dot_prod += weights[weightIndex] * layerInputs[j];
            }      

                float output = dot_prod + bias[i];
            
                softmaxBuffer[i] = output;
            }      
            
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


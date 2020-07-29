// activation function
#define RELU(x) x > 0 ? x : 0

__kernel void inputLayer(
                        __write_only pipe float __attribute__((blocking)) ILOutPipe0,
                        __write_only pipe float __attribute__((blocking)) ILOutPipe1,
                        __write_only pipe float __attribute__((blocking)) ILOutPipe2,
                        __write_only pipe float __attribute__((blocking)) ILOutPipe3, 
                        __global float * restrict inputs,       
                        int numberOfNeurons,
                        int totalNumberOfExamples)
{
        // loop over all the input examples
        for(int currentExample = 0; currentExample < totalNumberOfExamples; currentExample++)
        {
            // Loop over each neuron
            #pragma unroll
            for(int i = 0; i < numberOfNeurons; i++)
            {
                float output = inputs[currentExample * numberOfNeurons + i]; 

                // write outputs to pipes
                switch(i){
                    case 0:                     
                        write_pipe(ILOutPipe0, &output);
                        break;
                    case 1:
                        write_pipe(ILOutPipe1, &output);
                        break;
                    case 2: 
                        write_pipe(ILOutPipe2, &output);
                        break;
                    case 3: 
                        write_pipe(ILOutPipe3, &output);
                        break;
                    default:
                        break;
                }           
            }
        }
}

__kernel void hiddenLayer0(
                        __read_only pipe float __attribute__((blocking)) ILOutPipe0,
                        __read_only pipe float __attribute__((blocking)) ILOutPipe1,
                        __read_only pipe float __attribute__((blocking)) ILOutPipe2,
                        __read_only pipe float __attribute__((blocking)) ILOutPipe3,
                        __write_only pipe float __attribute__((blocking)) HL0OutPipe0,
                        __write_only pipe float __attribute__((blocking)) HL0OutPipe1,
                        __write_only pipe float __attribute__((blocking)) HL0OutPipe2,
                        __write_only pipe float __attribute__((blocking)) HL0OutPipe3,
                        __write_only pipe float __attribute__((blocking)) HL0OutPipe4,
                        __write_only pipe float __attribute__((blocking)) HL0OutPipe5,
                        __write_only pipe float __attribute__((blocking)) HL0OutPipe6,
                        __write_only pipe float __attribute__((blocking)) HL0OutPipe7,
                        __global float * restrict weights,
                        __global float * restrict bias,
                        __global float * restrict layerInputs, 
                        int numberOfNeurons, 
                        int numberOfInputs,
                        int totalNumberOfExamples)
{
        // loop over all examples
        for(int currentExample = 0; currentExample < totalNumberOfExamples; currentExample++)
        {
            read_pipe(ILOutPipe0, &layerInputs[0]);
            read_pipe(ILOutPipe1, &layerInputs[1]);
            read_pipe(ILOutPipe2, &layerInputs[2]);
            read_pipe(ILOutPipe3, &layerInputs[3]);
        
            // Loop over each neuron
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
                    int weightIndex = numberOfNeurons * j + i; 
                    dot_prod += weights[weightIndex] * layerInputs[j];
                }      

                // use RELU activation function and write the neurons output to the output pipe   
                float val    = dot_prod + bias[i];
                float output =  RELU(val);

                switch(i){
                    case 0:
                        write_pipe(HL0OutPipe0, &output);
                        break;
                    case 1:
                        write_pipe(HL0OutPipe1, &output);
                        break;
                    case 2: 
                        write_pipe(HL0OutPipe2, &output);
                        break;
                    case 3: 
                        write_pipe(HL0OutPipe3, &output);
                        break;
                    case 4:
                        write_pipe(HL0OutPipe4, &output);
                        break;
                    case 5:
                        write_pipe(HL0OutPipe5, &output);
                        break;
                    case 6: 
                        write_pipe(HL0OutPipe6, &output);
                        break;
                    case 7: 
                        write_pipe(HL0OutPipe7, &output);
                        break;
                    default:
                        break;
                } 
            }   
        }
}

__kernel void outputLayer(
                        __read_only pipe float __attribute__((blocking)) HL0OutPipe0,
                        __read_only pipe float __attribute__((blocking)) HL0OutPipe1,
                        __read_only pipe float __attribute__((blocking)) HL0OutPipe2,
                        __read_only pipe float __attribute__((blocking)) HL0OutPipe3,
                        __read_only pipe float __attribute__((blocking)) HL0OutPipe4,
                        __read_only pipe float __attribute__((blocking)) HL0OutPipe5,
                        __read_only pipe float __attribute__((blocking)) HL0OutPipe6,
                        __read_only pipe float __attribute__((blocking)) HL0OutPipe7,
                        __global float * restrict outputs,
                        __global float * restrict weights,
                        __global float * restrict bias,
                        __global float * restrict layerInputs,
                        __global float * restrict softmaxBuffer,
                        int numberOfNeurons,
                        int numberOfInputs,
                        int totalNumberOfExamples)
{
        // loop over all examples
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
            
            // Loop over each neuron
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

                float temp = exp(softmaxBuffer[i] - offset);
                outputs[currentExample * numberOfNeurons + i] = temp;
            }        
        }
}


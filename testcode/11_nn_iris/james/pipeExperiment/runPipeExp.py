from __future__ import print_function
import subprocess

template = """__kernel void producer(
{{producer_arguments}}
)
{
float dummyValue = 0;

{{writes}}

}

__kernel void consumer(
{{consumer_arguments}}
)
{
float dummyValue = 0;

{{reads}}
}"""


class Pipe:
    def __init__(self, name, blocking=True, depth=1, type="float"):
        self.name = name
        self.blocking = blocking
        self.depth = depth
        self.type = type

    def generateRead(self, arrayPointer):
        return "read_pipe({}, {});".format(self.name, arrayPointer)

    def generateWrite(self, arrayPointer):
        return "write_pipe({}, {});".format(self.name, arrayPointer)

    def generateBlockingParam(self):
        return "__attribute__((blocking))" if self.blocking else ""

    def generateInputParam(self):
        return "__read_only pipe {} {} __attribute__((depth({}))) {}".format(self.type, self.generateBlockingParam(), self.depth, self.name)

    def generateOutputParam(self):
        return "__write_only pipe {} {} __attribute__((depth({}))) {}".format(self.type, self.generateBlockingParam(), self.depth, self.name)


pipe_base_name = "Pipe_"

with open("run_aoc.sh", mode="w") as command_file:

	for num_of_pipes in range(1, 10) + range(10, 100, 10) + range(100, 1000, 100) + range(1000, 10001, 1000):
	    pipes = []

	    for i in range(num_of_pipes):
		pipes.append(Pipe("{}{}".format(pipe_base_name, i)))

	    producer_arg_string = ""
	    consumer_arg_string = ""
	    writes = ""
	    reads = ""

	    for idx, pipe in enumerate(pipes):

		producer_arg_string += pipe.generateOutputParam()
		consumer_arg_string += pipe.generateInputParam()

		if idx != (len(pipes) - 1):
		    producer_arg_string += ",\n"
		    consumer_arg_string += ",\n"

		writes += "{}\n".format(pipe.generateWrite("&dummyValue"))
		reads += "{}\n".format(pipe.generateRead("&dummyValue"))

	    program = template.replace("{{producer_arguments}}", producer_arg_string).replace(
		"{{consumer_arguments}}", consumer_arg_string).replace("{{reads}}", reads).replace("{{writes}}", writes)

	    ocl_file_name = "pipe_experiment_{}_pipes.cl".format(num_of_pipes)

	    with open(ocl_file_name, mode="w") as file:
		file.write(program)

	    command = "aoc -w -c -report -board=p385_hpc_d5 {}\n".format(ocl_file_name)
	    command_file.write(command)

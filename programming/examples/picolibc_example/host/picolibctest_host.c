#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "rv_stdio.h"
#include "tapasco.h"
#include "platform.h"

static void check_tapasco(tapasco_res_t const result)
{
	if(result != TAPASCO_SUCCESS)
	{
		fprintf(stderr, "tapasco fatal error: %s\n", tapasco_strerror(result));
		exit(result);
	}
}

/**
 * Read binary file containing the code running on the RISC-V core
 */
size_t read_binary_file(char * filename, unsigned char ** buffer){
	FILE *fp;
	size_t size;
	fp = fopen(filename, "rb");
	
	if (fp == NULL){
	    printf("ERROR: Could not read from file %s \n", filename);
	    exit(1);
	}
	
	fseek(fp, 0, SEEK_END);
	size = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	printf("File size: %zd bytes\n", size);
	*buffer = (unsigned char*) malloc(size);
	size_t num_elements = fread(*buffer, sizeof(**buffer), size, fp);
	
	if(num_elements != size){
		printf("ERROR: Could not read the whole file: %zd of %zd\n", num_elements, size);
		exit(1);
	}
	
	fclose(fp);
	printf("Finished reading binary file\n");
	return size;
}

int main(int argc, char** argv)
{
	
	
	if(argc < 2)
	{
		printf("Missing program code, exiting...");
		exit(1);
	}
	
	
	unsigned char* program_buffer;
	size_t program_size = read_binary_file(argv[1], &program_buffer);
	
	// Setup device context
	tapasco_ctx_t* ctx;
	tapasco_devctx_t* dev;
	
	check_tapasco(tapasco_init(&ctx));
	check_tapasco(tapasco_create_device(ctx, 0, &dev, TAPASCO_DEVICE_CREATE_EXCLUSIVE));

	// find out kernelID of the available RISC-V PE
	platform_info_t platform_info;
	check_tapasco(tapasco_device_info(dev, &platform_info));
	int i = 0;
	platform_kernel_id_t kernelID = 0;

	do {
		kernelID = platform_info.composition.kernel[i];
		++i;
	} while ((kernelID < 1742 || kernelID > 1749) && i < PLATFORM_NUM_SLOTS);

	if (kernelID < 1742 || kernelID > 1749) {
		printf("No suitable PE found on device\n");
		return 0;
	}

	printf("Using kernelID: %0d\n", kernelID);

	
	
	// Setup job
	tapasco_job_id_t job_id;
	check_tapasco(tapasco_device_acquire_job_id(dev, &job_id, kernelID, TAPASCO_DEVICE_ACQUIRE_JOB_ID_BLOCKING));
	
	// Copy program to instruction memory
	check_tapasco(tapasco_device_job_set_arg_transfer(dev, job_id, 0, program_size, program_buffer, TAPASCO_DEVICE_ALLOC_FLAGS_PE_LOCAL, TAPASCO_COPY_DIRECTION_TO));
	
	/* Start of custom stuff like populating data memory or setting args in the RVController that are later used by the processor*/
	
	// create buffers for stdin and stdout
	char *input_string = "This is the input string!\n12345\n";
	int input_length = strlen(input_string);
	char stdout_array[1024];
	int output_length = sizeof(stdout_array);
		
	// setup stdio buffer
	tapasco_handle_t handle_stdout, handle_stdin;
	check_tapasco(setup_stdio(dev, job_id, &handle_stdout, output_length, &handle_stdin, input_string, input_length));
	
	/* End of custom data transfer */
	
	
	// Start job
	printf("Starting job\n");
	check_tapasco(tapasco_device_job_launch(dev, job_id, TAPASCO_DEVICE_JOB_LAUNCH_BLOCKING));
	printf("Finished Job\n");
	
	// Get return value (if neccessary)
	// -> no return value in this example, check general coding examples
	
	// teardown stdio buffers and get stdout buffer content
	check_tapasco(teardown_stdio(dev, handle_stdout, stdout_array, output_length, handle_stdin, input_length));
	printf("\n%s\n", stdout_array);
	
	// Teardown tapasco
	tapasco_device_release_job_id(dev, job_id);
	printf("Released job\n");
	tapasco_destroy_device(ctx, dev);
	printf("Destroyed device\n");
	tapasco_deinit(ctx);
	printf("Closed TaPaSCo context\n");
	
	
	// Free buffer that holds program and any other buffers.
	free(program_buffer);
	
	return 0;
}

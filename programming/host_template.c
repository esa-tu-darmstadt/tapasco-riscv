#include <stdio.h>
#include <stdlib.h>
#include "tapasco.h"
#include "platform.h"

#define VEXRISCV_PE_ID 1742
#define ORCA_PE_ID 1743
#define PICCOLO_PE_ID 1744

static void check_tapasco(tapasco_res_t const result)
{
	if(result != TAPASCO_SUCCESS)
	{
		fprintf(stderr, "tapasco fatal error: %s\n", tapasco_strerror(result));
		exit(result);
	}
}

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
	tapasco_ctx* ctx;
	tapasco_devctx_t* dev;
	
	check_tapasco(tapasco_init(&ctx));
	check_tapasco(tapasco_create_device(ctx, 0, &dev, TAPASCO_DEVICE_CREATE_EXCLUSIVE));
	
	// Setup job
	tapasco_job_id_t job_id;
	check_tapasco(tapasco_device_acquire_job_id(dev, &job_id, VEXRISCV_PE_ID, TAPASCO_DEVICE_ACQUIRE_JOB_ID_BLOCKING));
	
	// Copy program to instruction memory
	check_tapasco(tapasco_device_job_set_arg_transfer(dev, job_id, 0, program_size, program_buffer, TAPASCO_DEVICE_ALLOC_FLAGS_PE_LOCAL, TAPASCO_COPY_DIRECTION_TO));
	
	/* Start of custom stuff like populating data memory or setting args in the RVController that are later used by the processor*/
	
	
	
	/* End of custom data transfer */
	
	// Start job
	printf("Starting job\n");
	check_tapasco(tapasco_device_job_launch(dev, job_id, TAPASCO_DEVICE_JOB_LAUNCH_BLOCKING));
	printf("Finished Job\n");
	
	// Get return value (if neccessary)
	int retVal = 0;
	check_tapasco(tapasco_device_job_get_return(dev, job_id, sizeof(retVal), &retVal));
	
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

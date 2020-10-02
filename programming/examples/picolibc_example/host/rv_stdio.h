#pragma once

#include "tapasco.h"

tapasco_res_t setup_stdout(tapasco_devctx_t *dev, tapasco_job_id_t job_id, tapasco_handle_t *handle, size_t size);
tapasco_res_t setup_stdin(tapasco_devctx_t *dev, tapasco_job_id_t job_id, tapasco_handle_t *handle, void *buffer, size_t size);
tapasco_res_t setup_stdio(tapasco_devctx_t *dev, tapasco_job_id_t job_id, tapasco_handle_t *handle_stdout, size_t size_stdout, tapasco_handle_t *handle_stdin, void *buffer_stdin, size_t size_stdin);

tapasco_res_t teardown_stdout(tapasco_devctx_t *dev, tapasco_handle_t handle, void *buffer, size_t size);
void teardown_stdin(tapasco_devctx_t *dev, tapasco_handle_t handle, size_t size);
tapasco_res_t teardown_stdio(tapasco_devctx_t *dev, tapasco_handle_t handle_stdout, void *buffer_stdout, size_t size_stdout, tapasco_handle_t handle_stdin, size_t size_stdin);

/**
 * Allocates the handle for the stdout buffer and writes the respective control registers.
 */
tapasco_res_t setup_stdout(tapasco_devctx_t *dev, tapasco_job_id_t job_id, tapasco_handle_t *handle, size_t size) {
	tapasco_res_t ret_val;
	
	// allocate handle
	if((ret_val = tapasco_device_alloc(dev, handle, size, TAPASCO_DEVICE_ALLOC_FLAGS_NONE)) != TAPASCO_SUCCESS) {
		fprintf(stderr, "Failed to allocate device memory for stdout buffer\n");
		return ret_val;
	}
	
	// set control registers
	if ((ret_val = tapasco_device_job_set_arg(dev, job_id, 6, sizeof(tapasco_handle_t), handle)) != TAPASCO_SUCCESS)
		return ret_val;
	
	return tapasco_device_job_set_arg(dev, job_id, 7, sizeof(size), &size);
}

/**
 * Allocates the handle for the stdin buffer, copies the data to the allocated device memory
 * and writes the respective control registers.
 */
tapasco_res_t setup_stdin(tapasco_devctx_t *dev, tapasco_job_id_t job_id, tapasco_handle_t *handle, void *buffer, size_t size) {
	tapasco_res_t ret_val;
	
	// allocate handle
	if((ret_val = tapasco_device_alloc(dev, handle, size, TAPASCO_DEVICE_ALLOC_FLAGS_NONE)) != TAPASCO_SUCCESS) {
		fprintf(stderr, "Failed to allocate device memory for stdin buffer\n");
		return ret_val;
	}
	
	// copy data to device memory
	if ((ret_val = tapasco_device_copy_to(dev, buffer, *handle, size, TAPASCO_DEVICE_COPY_BLOCKING)) != TAPASCO_SUCCESS) {
		fprintf(stderr, "Failed to copy data to device memory for stdin\n");
		return ret_val;
	}
	
	// set control registers
	if ((ret_val = tapasco_device_job_set_arg(dev, job_id, 8, sizeof(tapasco_handle_t), handle)) != TAPASCO_SUCCESS)
		return ret_val;
	
	return tapasco_device_job_set_arg(dev, job_id, 9, sizeof(size), &size);	
	
}

/**
 * Sets up buffers for both stdout and stdin by calling the respective functions.
 */
tapasco_res_t setup_stdio(tapasco_devctx_t *dev, tapasco_job_id_t job_id, tapasco_handle_t *handle_stdout, size_t size_stdout, tapasco_handle_t *handle_stdin, void *buffer_stdin, size_t size_stdin) {
	tapasco_res_t ret_val;
	ret_val = setup_stdout(dev, job_id, handle_stdout, size_stdout);
	if (ret_val != TAPASCO_SUCCESS)
		return ret_val;
	
	return setup_stdin(dev, job_id, handle_stdin, buffer_stdin, size_stdin);
}

/**
 * Copies stdout data from the device memory and frees the allocated handle.
 */
tapasco_res_t teardown_stdout(tapasco_devctx_t *dev, tapasco_handle_t handle, void *buffer, size_t size) {
	tapasco_res_t ret_val;
	if ((ret_val = tapasco_device_copy_from(dev, handle, buffer, size, TAPASCO_DEVICE_COPY_BLOCKING)) != TAPASCO_SUCCESS) {
		fprintf(stderr, "Failed to copy data from device memory for stdout\n");
		return ret_val;
	}
	
	tapasco_device_free(dev, handle, size, TAPASCO_DEVICE_ALLOC_FLAGS_NONE);
	return TAPASCO_SUCCESS;
}

/**
 * Frees the allocated handle for stdin.
 */
void teardown_stdin(tapasco_devctx_t *dev, tapasco_handle_t handle, size_t size) {
	tapasco_device_free(dev, handle, size, TAPASCO_DEVICE_ALLOC_FLAGS_NONE);
}

/**
 * Tears down both handles of stdin and stdout by calling the respective functions.
 */
tapasco_res_t teardown_stdio(tapasco_devctx_t *dev, tapasco_handle_t handle_stdout, void *buffer_stdout, size_t size_stdout, tapasco_handle_t handle_stdin, size_t size_stdin) {
	teardown_stdin(dev, handle_stdin, size_stdin);
	return teardown_stdout(dev, handle_stdout, buffer_stdout, size_stdout);
}









































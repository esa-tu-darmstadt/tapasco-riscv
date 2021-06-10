#ifndef CAPN_997B72335B9C6AAF
#define CAPN_997B72335B9C6AAF
/* AUTO GENERATED - DO NOT EDIT */
#include <capnp_c.h>

#if CAPN_VERSION != 1
#error "version mismatch between capnp_c.h and generated code"
#endif

#ifndef capnp_nowarn
# ifdef __GNUC__
#  define capnp_nowarn __extension__
# else
#  define capnp_nowarn
# endif
#endif


#ifdef __cplusplus
extern "C" {
#endif

struct Request;
struct Response;

typedef struct {capn_ptr p;} Request_ptr;
typedef struct {capn_ptr p;} Response_ptr;

typedef struct {capn_ptr p;} Request_list;
typedef struct {capn_ptr p;} Response_list;

enum Request_RequestType {
	Request_RequestType_dtm = 0,
	Request_RequestType_dm = 1,
	Request_RequestType_register = 2,
	Request_RequestType_memory = 3,
	Request_RequestType_systemBus = 4,
	Request_RequestType_control = 5
};

enum Request_ControlType {
	Request_ControlType_halt = 0,
	Request_ControlType_resume = 1,
	Request_ControlType_step = 2,
	Request_ControlType_reset = 3
};

struct Request {
	enum Request_RequestType type;
	unsigned isRead : 1;
	uint32_t addr;
	uint32_t data;
	enum Request_ControlType ctrlType;
};

static const size_t Request_word_count = 2;

static const size_t Request_pointer_count = 0;

static const size_t Request_struct_bytes_count = 16;

struct Response {
	unsigned isRead : 1;
	uint32_t data;
	unsigned success : 1;
};

static const size_t Response_word_count = 1;

static const size_t Response_pointer_count = 0;

static const size_t Response_struct_bytes_count = 8;

Request_ptr new_Request(struct capn_segment*);
Response_ptr new_Response(struct capn_segment*);

Request_list new_Request_list(struct capn_segment*, int len);
Response_list new_Response_list(struct capn_segment*, int len);

void read_Request(struct Request*, Request_ptr);
void read_Response(struct Response*, Response_ptr);

void write_Request(const struct Request*, Request_ptr);
void write_Response(const struct Response*, Response_ptr);

void get_Request(struct Request*, Request_list, int i);
void get_Response(struct Response*, Response_list, int i);

void set_Request(const struct Request*, Request_list, int i);
void set_Response(const struct Response*, Response_list, int i);

#ifdef __cplusplus
}
#endif
#endif

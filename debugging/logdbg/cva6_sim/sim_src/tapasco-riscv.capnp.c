#include "tapasco-riscv.capnp.h"
/* AUTO GENERATED - DO NOT EDIT */
#ifdef __GNUC__
# define capnp_unused __attribute__((unused))
# define capnp_use(x) (void) x;
#else
# define capnp_unused
# define capnp_use(x)
#endif


Request_ptr new_Request(struct capn_segment *s) {
	Request_ptr p;
	p.p = capn_new_struct(s, 16, 0);
	return p;
}
Request_list new_Request_list(struct capn_segment *s, int len) {
	Request_list p;
	p.p = capn_new_list(s, len, 16, 0);
	return p;
}
void read_Request(struct Request *s capnp_unused, Request_ptr p) {
	capn_resolve(&p.p);
	capnp_use(s);
	s->type = (enum Request_RequestType)(int) capn_read16(p.p, 0);
	s->isRead = (capn_read8(p.p, 2) & 1) != 0;
	s->addr = capn_read32(p.p, 4);
	s->data = capn_read32(p.p, 8);
	s->ctrlType = (enum Request_ControlType)(int) capn_read16(p.p, 12);
}
void write_Request(const struct Request *s capnp_unused, Request_ptr p) {
	capn_resolve(&p.p);
	capnp_use(s);
	capn_write16(p.p, 0, (uint16_t) (s->type));
	capn_write1(p.p, 16, s->isRead != 0);
	capn_write32(p.p, 4, s->addr);
	capn_write32(p.p, 8, s->data);
	capn_write16(p.p, 12, (uint16_t) (s->ctrlType));
}
void get_Request(struct Request *s, Request_list l, int i) {
	Request_ptr p;
	p.p = capn_getp(l.p, i, 0);
	read_Request(s, p);
}
void set_Request(const struct Request *s, Request_list l, int i) {
	Request_ptr p;
	p.p = capn_getp(l.p, i, 0);
	write_Request(s, p);
}

Response_ptr new_Response(struct capn_segment *s) {
	Response_ptr p;
	p.p = capn_new_struct(s, 8, 0);
	return p;
}
Response_list new_Response_list(struct capn_segment *s, int len) {
	Response_list p;
	p.p = capn_new_list(s, len, 8, 0);
	return p;
}
void read_Response(struct Response *s capnp_unused, Response_ptr p) {
	capn_resolve(&p.p);
	capnp_use(s);
	s->isRead = (capn_read8(p.p, 0) & 1) != 0;
	s->data = capn_read32(p.p, 4);
	s->success = (capn_read8(p.p, 0) & 2) != 0;
}
void write_Response(const struct Response *s capnp_unused, Response_ptr p) {
	capn_resolve(&p.p);
	capnp_use(s);
	capn_write1(p.p, 0, s->isRead != 0);
	capn_write32(p.p, 4, s->data);
	capn_write1(p.p, 1, s->success != 0);
}
void get_Response(struct Response *s, Response_list l, int i) {
	Response_ptr p;
	p.p = capn_getp(l.p, i, 0);
	read_Response(s, p);
}
void set_Response(const struct Response *s, Response_list l, int i) {
	Response_ptr p;
	p.p = capn_getp(l.p, i, 0);
	write_Response(s, p);
}

#ifndef RINGBUF_HPP
#define RINGBUF_HPP

#include <vector>
#include <cstddef>


namespace dm
{
    class RingBuf
    {
    private:
        size_t size;
        std::vector<char> bytes;

        /* append at head */
        std::vector<char>::iterator head;
        /* cut from tail */
        std::vector<char>::iterator tail;

        void check_tegridy();

        void inc_head();
        void inc_tail();
    public:
        RingBuf(size_t size);

        size_t capacity() const;
        size_t content() const;

        void put(const char *buf, size_t len);
        void take(char *buf, size_t len);
        void remove(size_t len);
    };
}

#endif /* RINGBUF_HPP */
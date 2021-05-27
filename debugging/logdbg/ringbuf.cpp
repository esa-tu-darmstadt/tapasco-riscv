#include "ringbuf.hpp"

#include <stdexcept>


namespace dm
{
    void RingBuf::check_tegridy()
    {

    }

    void RingBuf::inc_head()
    {
        head++;

        if (head == bytes.end())
            head = bytes.begin();
    }

    void RingBuf::inc_tail()
    {
        tail++;

        if (tail == bytes.end())
            tail = bytes.begin();
    }

    RingBuf::RingBuf(size_t size) :
        size(size), bytes(size)
    {
        head = bytes.begin();
        tail = bytes.begin();
    }

    size_t RingBuf::capacity() const
    {
        size_t head_off = head - bytes.begin();
        size_t tail_off = tail - bytes.begin();

        if (head_off >= tail_off)
            return tail_off + (size - head_off);
        else
            return tail_off - head_off;
    }

    size_t RingBuf::content() const
    {
        size_t head_off = head - bytes.begin();
        size_t tail_off = tail - bytes.begin();

        if (head_off >= tail_off)
            return head_off - tail_off;
        else
            return head_off + (size - tail_off);
    }
   
    void RingBuf::put(const char *buf, size_t len)
    {
        if (capacity() < len)
            throw std::runtime_error("no space left");

        for (size_t i = 0; i < len; ++i) {
            *head = buf[i];
            inc_head();
        }
    }

    void RingBuf::take(char *buf, size_t len)
    {
        if (content() < len)
            throw std::runtime_error("not enough in buffer");

        for (size_t i = 0; i < len; ++i) {
            buf[i] = *tail;
            inc_tail();
        }
    }

    void RingBuf::remove(size_t len)
    {
        if (content() < len)
            throw std::runtime_error("not enough in buffer");

        for (size_t i = 0; i < len; ++i)
            inc_tail();
    }
}